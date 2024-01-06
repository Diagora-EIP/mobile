import 'dart:convert';

import 'package:diagora/models/company_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:diagora/services/performance_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diagora/models/user_model.dart';
import 'package:diagora/models/role_model.dart';

/// Classe qui contient toutes les routes de l'API. Utilisez [route] pour créer une Uri.
class ApiRoutes {
  // static const String baseUrl = 'http://51.103.122.92:3000';
  static const String baseUrl = 'http://localhost:3000';

  // Authentification
  static const String registerUserRoute = '/user/register'; // POST
  static const String loginUserRoute = '/user/login'; // POST
  static const String logoutUserRoute = '/user/logout'; // POST
  static const String resetPasswordRoute = '/resetPassword'; // POST
  static const String updatePasswordRoute = '/resetPassword'; // PATCH
  static const String updatePasswordByTokenRoute = '/resetPassword/:reset_token'; // PATCH

  // Utilisateur
  static const String getUserRoute = '/user'; // GET
  static const String getUserByIdRoute = '/user/:id'; // GET
  static const String updateUserRoute = '/user'; // PATCH
  static const String updateUserByIdRoute = '/user/:id'; // PATCH
  static const String registerManagerRoute = '/user/registerManager'; // POST
  static const String getUserRolesRoute = '/userRoles'; // GET
  static const String checkSessionRoute = '/session'; // GET

  // Admin - Utilisateurs
  static const String getAdminUsersRoute = '/admin/users'; // GET
  static const String updateAdminUserRoute = '/admin/user/:id'; // PATCH
  static const String getAdminUserRolesRoute = '/admin/userRoles/:id'; // GET
  static const String updateAdminUserRolesRoute = '/admin/userRoles/:id'; // PATCH

  // Entreprises
  static const String getCompanyRoute = '/company'; // GET

  // Admin - Entreprises
  static const String getAdminCompanyRoute = '/admin/company/:company_id'; // GET
  static const String getAdminCompaniesRoute = '/admin/companies'; // GET
  static const String createAdminCompanyRoute = '/admin/company'; // POST
  static const String updateAdminCompanyRoute = '/admin/company/:company_id'; // PATCH

  // Commandes
  static const String createOrderRoute = '/order/create'; // POST
  static const String getOrdersBetweenDatesRoute = '/order/get-between-date'; // GET
  static const String updateOrderRoute = '/order/update/:order_id'; // PATCH
  static const String deleteOrderRoute = '/order/delete/:order_id'; // DELETE

  // Itineraries
  static const String getItineraryRoute = '/itinerary/get/:itinerary_id'; // GET

  // Admin - Commandes
  static const String getAllAdminOrdersRoute = '/admin/orders'; // GET

  // Schedule
  static const String createScheduleRoute = '/schedule/create'; // POST
  static const String getScheduleRoute = '/schedule/get-between-date'; // POST

  // Vehicules
  static const String createVehicleRoute = '/vehicle'; // POST
  static const String updateVehicleRoute = '/vehicle/:vehicle_id'; // PATCH
  static const String deleteVehicleRoute = '/vehicle/:vehicle_id'; // DELETE
  static const String getVehicleRoute = '/vehicle/:vehicle_id'; // GET
  static const String getUserVehiclesRoute = '/vehicles'; // GET
  static const String getUserCompanyVehiclesRoute = '/user/:id/vehicles'; // GET

  // Admin - Vehicules
  static const String createAdminVehicleRoute = '/admin/vehicle/:company_id'; // POST
  static const String updateAdminVehicleRoute = '/admin/vehicle/:vehicle_id'; // PATCH
  static const String deleteAdminVehicleRoute = '/admin/vehicle/:vehicle_id'; // DELETE
  static const String getAdminVehicleInfoRoute = '/admin/vehicle/:vehicle_id'; // GET
  static const String getAdminCompanyVehiclesRoute = '/admin/company/:company_id/vehicles'; // GET
  static const String getUserAdminVehiclesRoute = '/admin/user/:user_id/vehicles'; // GET
  static const String getAllAdminVehiclesRoute = '/admin/vehicles'; // GET

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
  static Role? _role;
  Role? get role => _role;
  static String? _token;

  /// Permet d'obtenir une instance de [ApiService].
  static ApiService getInstance() {
    if (_prefs == null) {
      SharedPreferences.getInstance().then((value) {
        _prefs = value;
        _token ??= _prefs?.getString('token');
        _user ??= _prefs?.getString('user') != null ? User.fromJson(json.decode(_prefs!.getString('user')!)) : null;
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
      Uri url = ApiRoutes.route(ApiRoutes.loginUserRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {'email': email.toLowerCase(), 'password': password, 'remember': remember},
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('token', responseData['token']);
        _token = responseData['token'];
        _prefs?.setString('user', json.encode(responseData));
        _user = User.fromJson(responseData);
        _logger.i(responseData);
        if (client != _httpClient) {
          return true;
        }
        analytics.logLogin(loginMethod: 'email').ignore();
        return true;
      } else {
        _logger.e('login() failed with status code ${response.statusCode}');
        _logger.e(response.body);
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
      Uri url = ApiRoutes.route(ApiRoutes.registerUserRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {'email': email.toLowerCase(), 'name': name, 'password': password},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('token', responseData['token']);
        _token = responseData['token'];
        _prefs?.setString('user', json.encode(responseData));
        _user = User.fromJson(responseData);
        if (client != _httpClient) {
          return true;
        }
        analytics.logSignUp(signUpMethod: 'email').ignore();
        _logger.i(responseData);
        return true;
      } else {
        _logger.e('register() failed with status code ${response.statusCode}');
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
      Uri url = ApiRoutes.route(ApiRoutes.logoutUserRoute);
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
      _role = null;
      _token = null;
      analytics.logEvent(name: 'logout').ignore();
      if (response.statusCode == 200) {
        _logger.i('Logout successful');
        return true;
      } else {
        _logger.e('logout() failed with status code ${response.statusCode}');
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
  Future<Role?> fetchRoles({
    int? userId,
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url;
      if (userId == null || userId == _user?.id) {
        url = ApiRoutes.route(ApiRoutes.getUserRolesRoute);
      } else {
        url = ApiRoutes.route(ApiRoutes.getAdminUserRolesRoute.replaceAll(':id', userId.toString()));
      }
      Response response = await client.get(
        url,
        headers: {"Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        _role = Role.fromJson(responseData[0]);
        return (_role);
      } else {
        _logger.e('fetchRoles() failed with status code ${response.statusCode}');
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
  Future<bool> patchRoles(
    Role roleData, {
    int? userId,
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url;
      if (userId == null || userId == _user?.id) {
        url = ApiRoutes.route(ApiRoutes.getUserRolesRoute);
      } else {
        url = ApiRoutes.route(ApiRoutes.updateAdminUserRolesRoute.replaceAll(':id', userId.toString()));
      }
      Response response = await client.patch(
        url,
        headers: {"Authorization": "Bearer ${_token!}", "Content-Type": "application/json"},
        body: json.encode(roleData.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (true);
      } else {
        _logger.e('patchRoles() failed with status code ${response.statusCode}');
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
      client ??= _httpClient;
      Uri url;
      if (userId == null || userId == _user?.id) {
        url = ApiRoutes.route(ApiRoutes.getUserRoute);
      } else {
        url = ApiRoutes.route(ApiRoutes.getUserByIdRoute.replaceAll(':id', userId.toString()));
      }
      Response response = await client.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        User user = User.fromJson(responseData);
        _logger.i(responseData);
        return (user);
      } else {
        _logger.e('fetchUser() failed with status code ${response.statusCode}');
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
      client ??= _httpClient;
      Uri url;
      if (userId == null || userId == _user?.id) {
        url = ApiRoutes.route(ApiRoutes.getUserRoute);
      } else {
        url = ApiRoutes.route(ApiRoutes.updateUserByIdRoute.replaceAll(':id', userId.toString()));
      }
      Response response = await client.patch(
        url,
        headers: {"Authorization": "Bearer ${_token!}", "Content-Type": "application/json"},
        body: json.encode(userData.toJson()),
      );
      if (response.statusCode == 200) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (true);
      } else {
        _logger.e('patchUser() failed with status code ${response.statusCode}');
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
      Uri url = ApiRoutes.route(ApiRoutes.getAdminUsersRoute);
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
        for (var user in responseData) {
          users.add(User.fromJson(user));
        }
        return (users);
      } else {
        _logger.e('fetchUsers() failed with status code ${response.statusCode}: ${response.body}');
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
      Uri url = ApiRoutes.route(ApiRoutes.resetPasswordRoute);
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
        _logger.e('resetPasswordWithoutToken() failed with status code ${response.statusCode}: ${response.body}');
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
      Uri url = ApiRoutes.route(ApiRoutes.resetPasswordRoute);
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
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // dynamic responseData = json.decode(response.body);
        // _logger.i(responseData);
        return true;
      } else {
        _logger.e('generatePasswordToken() failed with status code ${response.statusCode}: ${response.body}');
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
      Uri url = ApiRoutes.route(ApiRoutes.updatePasswordByTokenRoute.replaceAll(':reset_token', token));
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
        _logger.e('resetPasswordWithToken() failed with status code ${response.statusCode}: ${response.body}');
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
  Future<String> calendarOrders(
    DateTime begin,
    DateTime end, {
    Client? client,
  }) async {
    String beginTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toLocal());
    String endTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toLocal());
    client ??= _httpClient;

    Uri url =
        ApiRoutes.route("${ApiRoutes.getOrdersBetweenDatesRoute}?start_date=$beginTimeStamp&end_date=$endTimeStamp");

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        return (response.body);
      } else {
        _logger.e("calendarOrders() failed with status code ${response.statusCode}: ${response.body}");
        return "false";
      }
    } catch (e) {
      _logger.e(e.toString());
      return "false";
    }
  }

  Future<bool> addDelveryAutomatique(
    String name,
    String address,
    DateTime chosenDate,
    DateTime todayDate, {
    Client? client,
  }) async {
    Uri url = ApiRoutes.route(ApiRoutes.createScheduleRoute);
    client ??= _httpClient;

    String deliveryDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(chosenDate.toLocal());
    // String orderDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(todayDate.toLocal());

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
        body: json.encode({
          "delivery_date": deliveryDate,
          "estimated_time": 3600,
          "actual_time": 1800,
          "order_date": deliveryDate,
          "description": name,
          "delivery_address": address,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.d(response.body);
        dynamic responseData = json.decode(response.body);
        String itineraryId = responseData['itinerary_id'];
        String itineraryDate = responseData['delivery_date'];
        String? listItineraryId = _prefs?.getString("itineraire_id");
        String? listItineraryDate = _prefs?.getString("itineraire_date");

        if (listItineraryId == null || listItineraryDate == null) {
          _prefs?.setString("itineraire_id", json.encode([]));
          _prefs?.setString("itineraire_date", json.encode([]));
          listItineraryId = _prefs?.getString("itineraire_id");
          listItineraryDate = _prefs?.getString("itineraire_date");
        }
        if (itineraryId != '0' && listItineraryId != null && listItineraryDate != null) {
          dynamic listItinerary = json.decode(listItineraryId);
          dynamic listDate = json.decode(listItineraryDate);
          if (listItinerary.contains(itineraryId)) {
            _logger.d("Itinerary already exist: ", itineraryId);
            return Future.value(true);
          }
          listDate.add(itineraryDate);
          listItinerary.add(itineraryId);
          _prefs?.setString("itineraire_id", json.encode(listItinerary));
          _prefs?.setString("itineraire_date", json.encode(listDate));
        }
        return Future.value(true);
      }
    } catch (e) {
      _logger.d(e);
      return Future.value(false);
    }
    _logger.d("Error in addDelveryAutomatique");
    return Future.value(false);
  }

  Future<String> getSchedule(
    DateTime begin,
    DateTime end, {
    Client? client,
  }) async {
    String beginTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toLocal());
    String endTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toLocal());
    client ??= _httpClient;
    Uri url = ApiRoutes.route("${ApiRoutes.getScheduleRoute}?start_date=$beginTimeStamp&end_date=$endTimeStamp");
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
      );
      _logger.d(response.statusCode);
      _logger.d(response.body);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return Future.value(response.body);
      } else {
        _logger.e("getSchedule() failed with status code ${response.statusCode}: ${response.body}");
        return Future.value("false");
      }
    } catch (e) {
      _logger.e(e.toString());
      return Future.value("false");
    }
  }

  /// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
  ///
  /// The[begin], [end] parameter are required and cannot be null.
  /// The output value will be the shipment date if the call succeed.
  /// If [response.statusCode] is not 200 or 202, this function will return "false".
  Future<String> mapItinenaries(
    DateTime begin,
    DateTime end, {
    Client? client,
  }) async {
////////////////////////// test
    // String dateString1 = '2023-06-08 16:00:00.000';
    // DateTime begin = DateTime.parse(dateString1);

    // String dateString = '2023-06-08 20:00:00.000';
    // DateTime end = DateTime.parse(dateString);
////////////////////////// end test
    client ??= _httpClient;

    String schedule = await getSchedule(begin, end);

    if (schedule == "false" || schedule == "[]") {
      return "false";
    }
    List<dynamic> scheduleData = json.decode(schedule);
    String itineraryId = "none";

    for (var i = 0; i < scheduleData.length; i++) {
      if (scheduleData[i]["itinerary_id"] != 0) {
        itineraryId = scheduleData[i]["itinerary_id"];
        break;
      }
    }
    if (itineraryId == "none" || itineraryId == "0") {
      return "false";
    }

    Uri url = ApiRoutes.route(ApiRoutes.getItineraryRoute.replaceAll(":itinerary_id", itineraryId));
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
      );
      _logger.d(response.statusCode);
      _logger.d(response.body);
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
    DateTime end, {
    Client? client,
  }) async {
////////////////////////// test
    // String dateString1 = '2023-06-08 16:00:00.000';
    // DateTime begin = DateTime.parse(dateString1);

    // String dateString = '2023-06-08 20:00:00.000';
    // DateTime end = DateTime.parse(dateString);
////////////////////////// end test

    String beginTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toLocal());
    String endTimeStamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toLocal());
    client ??= _httpClient;
    Uri url;
    url = ApiRoutes.route("${ApiRoutes.getOrdersBetweenDatesRoute}?start_date=$beginTimeStamp&end_date=$endTimeStamp");
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        _logger.d(response.body);
        List<dynamic> responseData = json.decode(response.body);
        int nbDelivery = responseData.length;
        return (nbDelivery);
      } else {
        return -1;
      }
    } catch (e) {
      _logger.e(e.toString());
      return -1;
    }
  }

  // Future<bool> addUserSchedule(
  //   int userId,
  //   dynamic schedule, {
  //   Client? client,
  //   bool injectToken = true,
  // }) async {
  //   client ??= _httpClient;
  //   Uri url = ApiRoutes.route(ApiRoutes.userScheduleRoute.replaceAll(':user_id', userId.toString()));
  //   try {
  //     final response = await client.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer ${_token!}"
  //       },
  //       body: json.encode(schedule),
  //     );
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       dynamic responseData = json.decode(response.body);
  //       _logger.i(responseData);
  //       return (true);
  //     } else {
  //       _logger.e(
  //           'addUserSchedule() failed with status code ${response.statusCode}: ${response.body}');
  //       return (false);
  //     }
  //   } catch (e) {
  //     _logger.e(e.toString());
  //     return false;
  //   }
  // }

  // Future<bool> patchSchedule(
  //   int scheduleId,
  //   dynamic schedule, {
  //   Client? client,
  //   bool injectToken = true,
  // }) async {
  //   client ??= _httpClient;
  //   Uri url = ApiRoutes.route(ApiRoutes.scheduleRoute
  //       .replaceAll(":schedule_id", scheduleId.toString()));
  //   try {
  //     final response = await client.patch(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer ${_token!}"
  //       },
  //       body: json.encode(schedule),
  //     );
  //     if (response.statusCode == 200 || response.statusCode == 202) {
  //       _logger.i(response.body);
  //       return (true);
  //     } else {
  //       _logger.e(
  //           'patchSchedule() failed with status code ${response.statusCode}: ${response.body}');
  //       return (false);
  //     }
  //   } catch (e) {
  //     _logger.e(e.toString());
  //     return false;
  //   }
  // }

  Future<dynamic> getVehicules({
    Client? client,
    bool injectToken = true,
    int? userId,
  }) async {
    client ??= _httpClient;
    Uri url;
    if (userId == null || userId == _user!.id) {
      url = ApiRoutes.route(ApiRoutes.getUserVehiclesRoute);
    } else {
      url = ApiRoutes.route(ApiRoutes.getUserCompanyVehiclesRoute.replaceAll(":id", userId.toString()));
    }
    try {
      final response = await client.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        if (responseData == "User does not have any vehicle") {
          return ([]);
        }
        return (responseData);
      } else if (response.statusCode == 404) {
        return ([]);
      } else {
        _logger.e('getVehicules() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  Future<dynamic> addVehicule({
    Client? client,
    bool injectToken = true,
    int? userId,
    required String name,
    required String dimentions,
    required int capacity,
  }) async {
    client ??= _httpClient;
    Uri url;
    if (userId == null || userId == user?.id) {
      url = ApiRoutes.route(ApiRoutes.createVehicleRoute);
    } else {
      url = ApiRoutes.route(ApiRoutes.createAdminVehicleRoute.replaceAll(":company_id", userId.toString()));
    }
    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${_token!}"},
        body: json.encode({
          "userId": userId,
          "name": name,
          "dimentions": dimentions,
          "capacity": capacity,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (responseData);
      } else {
        _logger.e('addVehicule() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  Future<dynamic> editVehicule({
    Client? client,
    bool injectToken = true,
    required int vehiculeId,
    required int userId,
    required String name,
    required String dimentions,
    required int capacity,
  }) async {
    client ??= _httpClient;
    Uri url;
    if (userId == _user!.id) {
      url = ApiRoutes.route(ApiRoutes.updateVehicleRoute.replaceAll(":vehicle_id", vehiculeId.toString()));
    } else {
      url = ApiRoutes.route(ApiRoutes.updateAdminVehicleRoute.replaceAll(":vehicle_id", vehiculeId.toString()));
    }
    try {
      final response = await client.patch(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${_token!}"},
        body: json.encode({
          "userId": userId,
          "name": name,
          "dimentions": dimentions,
          "capacity": capacity,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        return (responseData);
      } else {
        _logger.e('editVehicule() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  Future<bool> deleteVehicule({
    Client? client,
    bool injectToken = true,
    required int vehiculeId,
  }) async {
    client ??= _httpClient;
    Uri url = ApiRoutes.route(ApiRoutes.deleteVehicleRoute.replaceAll(":vehicle_id", vehiculeId.toString()));
    try {
      final response = await client.delete(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${_token!}"},
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        _logger.i(response.body);
        return (true);
      } else {
        _logger.e('deleteVehicule() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de récupérer toutes les entreprises.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne une [List] de [Company]. Si la requête échoue, retourne null.
  Future<List<Company>?> fetchCompanies({
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.getAdminCompaniesRoute);
      Response response = await client.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        List<Company> companies = [];
        for (var company in responseData) {
          companies.add(Company.fromJson(company));
        }
        return (companies);
      } else {
        _logger.e('fetchCompanies() failed with status code ${response.statusCode}: ${response.body}');
        return (null);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (null);
    }
  }

  /// Permet de récupérer une entreprise.
  ///
  /// Prend en paramètre un [companyId] qui est un [int].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne une [Company]. Si la requête échoue, retourne null.
  Future<Company?> fetchCompany({
    int? companyId,
    Client? client,
  }) async {
    try {
      client ??= _httpClient;

      Uri url;
      if (companyId == null) {
        url = ApiRoutes.route(ApiRoutes.getCompanyRoute);
      } else {
        url = ApiRoutes.route(ApiRoutes.getAdminCompanyRoute.replaceAll(':company_id', companyId.toString()));
      }
      Response response = await client.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        if (response.body.isEmpty) return (null);
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        if (responseData is List) {
          return (Company.fromJson(responseData[0]));
        } else {
          return (Company.fromJson(responseData));
        }
      } else {
        _logger.e('fetchCompany() failed with status code ${response.statusCode}: ${response.body}');
        return (null);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (null);
    }
  }

  /// Permet de mettre à jour une entreprise.
  ///
  /// Prend en paramètre un [companyId] qui est un [int] et un [name] qui est une [String].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la requête a réussi.
  Future<bool> patchCompany(
    int companyId,
    String name,
    String address,
    List<int> usersIds, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.updateAdminCompanyRoute.replaceAll(':company_id', companyId.toString()));
      Response response = await client.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}",
        },
        body: json.encode({
          "name": name,
          "address": address,
          "user_ids": usersIds,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        _logger.i(response.body);
        return (true);
      } else {
        _logger.e('patchCompany() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (false);
    }
  }

  /// Permet de créer une entreprise.
  ///
  /// Prend en paramètre un [name] qui est une [String] et un [usersIds] qui est une [List] d'[int].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la requête a réussi.
  Future<bool> createCompany(
    String name,
    String address,
    List<int> usersIds, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.createAdminCompanyRoute);
      Response response = await client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_token!}",
        },
        body: json.encode({
          "name": name,
          "address": address,
          "user_ids": usersIds,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i(response.body);
        return (true);
      } else {
        _logger.e('createCompany() failed with status code ${response.statusCode}: ${response.body}');
        return (false);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (false);
    }
  }
}
