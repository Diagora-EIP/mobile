import os
import time

os.system("flutter test --coverage")

time.sleep(2)

os.system("lcov --remove coverage/lcov.info '*/test/*' -o coverage/lcov.info genhtml coverage/lcov.info -o coverage/html")

time.sleep(5)

os.system("open coverage/html/index.html")
