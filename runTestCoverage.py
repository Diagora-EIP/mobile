import os
import time

os.system("flutter test test/main_test.dart --coverage")

time.sleep(2)

os.system("genhtml -o coverage_report coverage/lcov.info")

time.sleep(5)

os.system("open coverage_report/index.html")
