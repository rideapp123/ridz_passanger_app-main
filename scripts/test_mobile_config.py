import copy
import unittest
from mobile_config import validate

class MobileConfigTest(unittest.TestCase):
    def setUp(self):
        self.registry = {
            "demo": {"API_BASE_URL": "https://demo.example.test", "SOCKET_BASE_URL": "https://demo.example.test",
                     "FIREBASE_PROJECT_ID": "demo-fixture"},
            "prod": {"API_BASE_URL": "https://prod.example.test", "SOCKET_BASE_URL": "https://prod.example.test",
                     "FIREBASE_PROJECT_ID": "prod-fixture"},
        }
        self.client = {"ENVIRONMENT": "demo", "STRIPE_PUBLISHABLE_KEY": "pk_test_" + "fixture",
                       "MAPBOX_PUBLIC_TOKEN": "pk.fixture"}

    def test_accepts_reviewed_demo(self):
        result = validate(self.registry, self.client, "demo")
        self.assertEqual(result["API_BASE_URL"], self.registry["demo"]["API_BASE_URL"])

    def test_rejects_wrong_flavor(self):
        with self.assertRaises(ValueError):
            validate(self.registry, self.client, "prod")

    def test_rejects_private_variable_names(self):
        for key in ("JWT_SECRET", "MONGODB_URI", "STRIPE_SECRET_KEY", "FIREBASE_SERVICE_ACCOUNT_JSON"):
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate(self.registry, dict(self.client, **{key: "fixture"}), "demo")

    def test_rejects_private_value_under_public_name(self):
        with self.assertRaises(ValueError):
            validate(self.registry, dict(self.client, SENTRY_DSN="sk_" + "test_" + "a" * 24), "demo")

    def test_rejects_wrong_api_and_socket(self):
        for key in ("API_BASE_URL", "SOCKET_BASE_URL"):
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate(self.registry, dict(self.client, **{key: "https://prod.example.test"}), "demo")

    def test_rejects_shared_firebase(self):
        self.registry["demo"]["FIREBASE_PROJECT_ID"] = self.registry["prod"]["FIREBASE_PROJECT_ID"]
        with self.assertRaises(ValueError):
            validate(self.registry, self.client, "demo")

    def test_rejects_shared_origins_with_trailing_slash(self):
        self.registry["prod"]["API_BASE_URL"] = self.registry["demo"]["API_BASE_URL"] + "/"
        with self.assertRaises(ValueError):
            validate(self.registry, self.client, "demo")

    def test_rejects_live_stripe_in_demo(self):
        with self.assertRaises(ValueError):
            validate(self.registry, dict(self.client, STRIPE_PUBLISHABLE_KEY="pk_live_" + "fixture"), "demo")

    def test_rejects_http_registry(self):
        self.registry["demo"]["API_BASE_URL"] = "http://demo.example.test"
        with self.assertRaises(ValueError):
            validate(self.registry, self.client, "demo")

    def test_rejects_multiline_config(self):
        with self.assertRaises(ValueError):
            validate(self.registry, dict(self.client, GOOGLE_MAPS_IOS_API_KEY="value\nOTHER=value"), "demo")

    def test_does_not_mutate_input(self):
        expected = copy.deepcopy(self.client)
        validate(self.registry, self.client, "demo")
        self.assertEqual(expected, self.client)
