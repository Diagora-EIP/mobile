import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:diagora/services/performance_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diagora/models/user_model.dart';
import 'package:diagora/models/permissions_model.dart';

/// Classe qui contient toutes les routes de l'API. Utilisez [route] pour créer une Uri.
class ApiRoutes {
  // static const String baseUrl = 'http://51.103.122.92:3000';
  static const String baseUrl = 'http://localhost:3000';
  // Authentification
  static const String loginRoute = '/user/login'; // POST
  static const String registerRoute = '/user/register'; // POST
  static const String logoutRoute = '/user/logout'; // POST
  static const String resetPasswordWithTokenRoute =
      '/user/reset-password/:token'; // POST
  static const String resetPasswordWithoutTokenRoute =
      '/user/reset-password'; // POST
  static const String resetPasswordGenerateToken =
      '/user/reset-password-generate';

  // User(s)
  static const String usersRoute = '/user'; // GET
  static const String userRoute = '/user/:id'; // GET, PATCH, DELETE
  static const String userPermissionsRoute = '/user/permissions/:id'; // GET
  // Permissions
  static const String permissionsRoute = '/permissions'; // GET
  static const String permissionRoute = '/permissions/:id'; // GET, PATCH
  // Entreprise(s)
  static const String companiesRoute = '/company'; // GET, POST
  static const String companyRoute = '/company/:id'; // GET, PATCH, DELETE
  // Événement(s)
  static const String userScheduleRoute =
      '/user/:user_id/schedule'; // GET, POST
  static const String scheduleRoute =
      '/schedule/:schedule_id'; // GET, PATCH, DELETE
  static const String scheduleAvailableSlotsRoute =
      '/schedule/avalaibleSlots/:user_id'; // GET
  // Véhicule(s)
  static const String vehiclesRoute = '/vehicle'; // GET, POST
  static const String vehicleRoute = '/vehicle/:id'; // GET, PATCH, DELETE
  // Itinéraire(s)
  static const String itinerariesUserRoute = '/itinerary/:user_id'; // GET, POST
  static const String itinerariesRoute = '/itinerary/:id'; // PATCH, DELETE

  // Calendrier
  static const String calendrierValues = 'user/:user_id/';

  /// Permet de créer l'URL complète d'une route.
  ///
  /// [route] est la route à utiliser.
  static Uri route(String route) => Uri.parse('$baseUrl$route');
}

/// Service qui permet de communiquer avec l'API.
/// Ce service est un singleton, pour l'instancier, il faut utiliser la méthode [getInstance].
class ApiService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Attributs généraux
  bool get isInitialized => _prefs != null;
  static SharedPreferences? _prefs;
  static final Client _httpClient = PerformanceHttpClient();
  static final Logger _logger = Logger();
  static const ApiService _instance = ApiService();

  // Constructeur par défaut
  const ApiService();

  // Informations sur l'utilisateur connecté
  static User? _user;
  User? get user => _user;
  static Permissions? _permissions;
  Permissions? get permissions => _permissions;
  static String? _token;

  /// Permet d'obtenir une instance de [ApiService].
  static ApiService getInstance() {
    if (_prefs == null) {
      SharedPreferences.getInstance().then((value) {
        _prefs = value;
        _token ??= _prefs?.getString('token');
        _user ??= _prefs?.getString('user') != null
            ? User.fromJson(json.decode(_prefs!.getString('user')!))
            : null;
      });
    }
    return _instance;
  }

  /// Permet de se connecter à l'application.
  ///
  /// Prend en paramètre un [email] et un [password].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client] et un [remember] qui est un [bool].
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.loginRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {
            'email': email.toLowerCase(),
            'password': password,
            'remember': remember
          },
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('token', responseData['token']);
        _token = responseData['token'];
        _prefs?.setString('user', json.encode(responseData['user']));
        _user = User.fromJson(responseData['user']);
        _logger.i(responseData);
        analytics.logLogin(loginMethod: 'email').ignore();
        return true;
      } else {
        _logger.e('Login failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de s'inscrire à l'application.
  ///
  /// Prend en paramètre un [name], un [email] et un [password].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si l'inscription a réussi.
  Future<bool> register(
    String name,
    String email,
    String password, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.registerRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {'email': email.toLowerCase(), 'name': name, 'password': password},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('user', json.encode(responseData['user']));
        _user = User.fromJson(responseData['user']);
        analytics.logSignUp(signUpMethod: 'email').ignore();
        _logger.i(responseData);
        return true;
      } else {
        _logger.e('Register failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de se déconnecter de l'application.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la déconnexion a réussi.
  Future<bool> logout({
    Client? client,
  }) async {
    try {
      if (_token == null || _token!.isEmpty) return false;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.logoutRoute);
      Response response = await client.post(
        url,
        body: json.encode({
          'token': _token,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      _prefs?.remove('token');
      _prefs?.remove('user');
      _user = null;
      _permissions = null;
      _token = null;
      analytics.logEvent(name: 'logout').ignore();
      if (response.statusCode == 200) {
        _logger.i('Logout successful');
        return true;
      } else {
        _logger.e('Logout failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de récupérer les permissions d'un utilisateur.
  ///
  /// Prend en paramètre optionnel un [userId] qui est un [int]. Si non spécifié, l'utilisateur connecté sera utilisé.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [Permissions] qui est le modèle de données des permissions. Si la requête échoue, retourne null.
  Future<Permissions?> fetchPermissions({
    int? userId,
    Client? client,
  }) async {
    try {
      userId ??= _user?.id;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.userPermissionsRoute.replaceAll(':id', userId.toString()));
      Response response = await client.get(
        url,
        headers: {"Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        _permissions = Permissions.fromJson(responseData);
        return (_permissions);
      } else {
        _logger.e(
            'fetchPermissions failed with status code ${response.statusCode}');
        return (null);
      }
    } catch (e) {
      _logger.e(e);
      return (null);
    }
  }

  /// Permet de PATCH les permissions d'un utilisateur.
  ///
  /// Prend en paramètre un [userId] (optionnel) qui est un [int] et un [permissions] qui est un [Permissions]. Si [userId] n'est pas spécifié, l'utilisateur connecté sera utilisé.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la requête a réussi.
  Future<bool> patchPermissions(
    Permissions permissionData, {
    int? userId,
    Client? client,
  }) async {
    try {
      userId ??= _user?.id;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.permissionRoute.replaceAll(':id', userId.toString()));
      Response response = await client.patch(
        url,
        headers: {
          "Authorization": "Bearer ${_token!}",
          "Content-Type": "application/json"
        },
        body: json.encode(permissionData.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (true);
      } else {
        _logger.e(
            'patchPermissions failed with status code ${response.statusCode}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (false);
    }
  }

  /// Permet de récupérer les informations d'un utilisateur.
  ///
  /// Prend en paramètre optionnel un [userId] qui est un [int]. Si non spécifié, l'utilisateur connecté sera utilisé.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [User]. Si la requête échoue, retourne null.
  Future<User?> fetchUser({
    int? userId,
    Client? client,
  }) async {
    try {
      userId ??= _user?.id;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.userRoute.replaceAll(':id', userId.toString()));
      Response response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${_token!}"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        User user = User.fromJson(responseData["user"]);
        _logger.i(responseData);
        return (user);
      } else {
        _logger.e('fetchUser failed with status code ${response.statusCode}');
        return (null);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (null);
    }
  }

  /// Permet de PATCH un utilisateur.
  ///
  /// Prend en paramètre un [userId] (optionnel) qui est un [int] et un [user] qui est un [User]. Si [userId] n'est pas spécifié, l'utilisateur connecté sera utilisé.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la requête a réussi.
  Future<bool> patchUser(
    User userData, {
    int? userId,
    Client? client,
  }) async {
    try {
      userId ??= _user?.id;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.userRoute.replaceAll(':id', userId.toString()));
      Response response = await client.patch(
        url,
        headers: {
          "Authorization": "Bearer ${_token!}",
          "Content-Type": "application/json"
        },
        body: json.encode(userData.toJson()),
      );
      if (response.statusCode == 200) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (true);
      } else {
        _logger.e('patchUser failed with status code ${response.statusCode}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (false);
    }
  }

  /// Permet de récupérer tout les utilisateurs.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne une [List] de [User]. Si la requête échoue, retourne null.
  Future<List<User>?> fetchUsers({
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.usersRoute);
      Response response = await client.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        List<User> users = [];
        for (var user in responseData["users"]) {
          users.add(User.fromJson(user));
        }
        _logger.i(responseData);
        return (users);
      } else {
        _logger.e(
            'patchUser failed with status code ${response.statusCode}: ${response.body}');
        return (null);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (null);
    }
  }

  /// Permet changer de mot de passe.
  ///
  /// Prend en paramètre un [email].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client]
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> resetPasswordWithoutToken(
    String email,
    String newPassword,
    int userId, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.resetPasswordWithoutTokenRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {"email": email, 'password': newPassword, "user_id": userId},
        ),
        headers: {
          'Content-Type': 'application/json',
          'MAILJET_API_KEY': 'a9ed23123ce9013f301d2c6c7b038105',
          'MAILJET_API_SECRET': 'c1582325f03a0be32490c4af7c012350'
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return true;
      } else {
        _logger.e(
            'Login failed with status code ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet changer de mot de passe.
  ///
  /// Prend en paramètre un [email].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client]
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> generatePasswordToken(
    String email, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.resetPasswordGenerateToken);
      Response response = await client.post(
        url,
        body: json.encode(
          {
            'email': email,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'MAILJET_API_KEY': 'a9ed23123ce9013f301d2c6c7b038105',
          'MAILJET_API_SECRET': 'c1582325f03a0be32490c4af7c012350'
        },
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        // dynamic responseData = json.decode(response.body);
        // _logger.i(responseData);
        return true;
      } else {
        _logger.e(
            'Login failed with status code ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet changer de mot de passe.
  ///
  /// Prend en paramètre un [email].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client]
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> resetPasswordWithToken(
    String token,
    String newPassword, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.resetPasswordWithTokenRoute.replaceAll(":token", token));
      Response response = await client.post(
        url,
        body: json.encode(
          {'password': newPassword},
        ),
        headers: {
          'Content-Type': 'application/json',
          'MAILJET_API_KEY': 'a9ed23123ce9013f301d2c6c7b038105',
          'MAILJET_API_SECRET': 'c1582325f03a0be32490c4af7c012350'
        },
      );
      if (response.statusCode == 200) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return true;
      } else {
        _logger.e(
            'Login failed with status code ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
  ///
  /// The[begin], [end] parameter are required and cannot be null.
  /// The output value will be the shipment date if the call succeed.
  /// If [response.statusCode] is not 200 or 202, this function will return "false".
  Future<String> calendarValues(
    DateTime begin,
    DateTime end,
    int userId, {
    Client? client,
  }) async {
    String beginTimeStamp =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toUtc());
    String endTimeStamp =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toUtc());
    client ??= _httpClient;

    String id;
    if (userId == -1) {
      return "false";
    } else {
      id = userId.toString();
    }

    Uri url = ApiRoutes.route(
        "/user/$id/schedule?begin=$beginTimeStamp&end=$endTimeStamp");

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${_token!}"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        return (response.body);
      } else {
        _logger.e(
            "calendarValues failed with status code ${response.statusCode}: ${response.body}");
        return "false";
      }
    } catch (e) {
      _logger.e(e.toString());
      return "false";
    }
  }

  /// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
  ///
  /// The[begin], [end] parameter are required and cannot be null.
  /// The output value will be the shipment date if the call succeed.
  /// If [response.statusCode] is not 200 or 202, this function will return "false".
  Future<String> mapValues(
    DateTime begin,
    DateTime end,
    int userId, {
    Client? client,
  }) async {
////////////////////////// test
    String dateString1 = '2023-06-08 16:00:00.000';
    DateTime begin = DateTime.parse(dateString1);

    String dateString = '2023-06-08 20:00:00.000';
    DateTime end = DateTime.parse(dateString);
////////////////////////// end test

    String beginTimeStamp = DateFormat("yyyy-MM-dd").format(begin.toUtc());
    String endTimeStamp = DateFormat("yyyy-MM-dd").format(end.toUtc());
    client ??= _httpClient;

    String id;
    if (userId == -1) {
      return "false";
    } else {
      id = userId.toString();
    }

    Uri url = ApiRoutes.route(
        "/user/$id/itinary?begin=$beginTimeStamp&end=$endTimeStamp");

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${_token!}"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        return (response.body);
      } else {
        return "false";
      }
    } catch (e) {
      _logger.e(e.toString());
      return "false";
    }
  }

  /// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
  ///
  /// The[begin], [end] parameter are required and cannot be null.
  /// The output value will be the shipment date if the call succeed.
  /// If [response.statusCode] is not 200 or 202, this function will return "false".
  Future<int> nbDeliveryToday(
    DateTime begin,
    DateTime end,
    int userId, {
    Client? client,
  }) async {
////////////////////////// test
    String dateString1 = '2023-06-08 16:00:00.000';
    DateTime begin = DateTime.parse(dateString1);

    String dateString = '2023-06-08 20:00:00.000';
    DateTime end = DateTime.parse(dateString);
////////////////////////// end test

    String beginTimeStamp = DateFormat("yyyy-MM-dd").format(begin.toUtc());
    String endTimeStamp = DateFormat("yyyy-MM-dd").format(end.toUtc());
    client ??= _httpClient;

    String id;
    if (userId == -1) {
      return (-1);
    } else {
      id = userId.toString();
    }

    Uri url = ApiRoutes.route(
        "/user/$id/itinary?begin=$beginTimeStamp&end=$endTimeStamp");

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${_token!}"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        List<dynamic> responseData = json.decode(response.body);
        int tt = 0;
        for (int i = 0; i < responseData.length; i++) {
          int nbStopPoints = responseData[i]['stop_point'].length;
          tt += nbStopPoints;
        }
        return (tt);
      } else {
        return -1;
      }
    } catch (e) {
      _logger.e(e.toString());
      return -1;
    }
  }

  Future<bool> addUserSchedule(
    int userId,
    dynamic schedule, {
    Client? client,
    bool injectToken = true,
  }) async {
    client ??= _httpClient;
    Uri url = ApiRoutes.route(
        ApiRoutes.userScheduleRoute.replaceAll(':user_id', userId.toString()));
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${_token!}"
        },
        body: json.encode(schedule),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (true);
      } else {
        _logger.e(
            'addUserSchedule failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  Future<bool> patchSchedule(
    int scheduleId,
    dynamic schedule, {
    Client? client,
    bool injectToken = true,
  }) async {
    client ??= _httpClient;
    Uri url = ApiRoutes.route(ApiRoutes.scheduleRoute
        .replaceAll(":schedule_id", scheduleId.toString()));
    try {
      final response = await client.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}"
        },
        body: json.encode(schedule),
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        _logger.i(response.body);
        return (true);
      } else {
        _logger.e(
            'addUserSchedule failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }
}
