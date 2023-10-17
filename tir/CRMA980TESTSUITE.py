import unittest

from CRMA980TESTCASE import CRMA980

suite = unittest.TestSuite()

suite.addTest(CRMA980('test_CRMA980_CT133'))

runner = unittest.TextTestRunner(verbosity=2)
result = runner.run(suite)

if len(result.errors) > 0 or len(result.failures) > 0:
    exit(1)