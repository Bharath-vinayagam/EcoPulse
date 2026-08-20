# backend/test_qa_suite.py
"""
Comprehensive QA Automation & Diagnostic Test Suite for EcoPulse ⚡ Application
Tests all 24 API Endpoints, Database Constraints, Schema Validations, and Edge Cases.
"""

import sys
import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:8000"

class QATestRunner:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.errors = []
        self.test_user_id = None
        self.test_username = f"qa_user_{int(datetime.now().timestamp())}"
        self.test_email = f"qa_{int(datetime.now().timestamp())}@test.com"
        self.test_password = "password123"
        self.test_expense_id = None
        self.test_goal_id = None

    def log(self, status, name, details=""):
        if status == "PASS":
            self.passed += 1
            print(f"  [PASS] {name}")
        else:
            self.failed += 1
            self.errors.append((name, details))
            print(f"  [FAIL] {name} -> {details}")

    def run_all(self):
        print("==================================================================")
        print("RUNNING COMPREHENSIVE QA AUTOMATED TEST SUITE")
        print("==================================================================")

        self.test_01_health_check()
        self.test_02_auth_register()
        self.test_03_auth_duplicate_register()
        self.test_04_auth_login()
        self.test_05_profile_get()
        self.test_06_profile_update()
        self.test_07_expense_create()
        self.test_08_expense_list()
        self.test_09_summary_get()
        self.test_10_ocr_scan_dynamic()
        self.test_11_ocr_scan_empty_fallback()
        self.test_12_transport_comparator_decimal()
        self.test_13_challenges_list()
        self.test_14_challenges_claim()
        self.test_15_goals_create()
        self.test_16_goals_list()
        self.test_17_goals_delete()
        self.test_18_analytics_monthly()
        self.test_19_analytics_forecast()
        self.test_20_eco_offset_analytics()
        self.test_21_plant_tree_action()
        self.test_22_csv_export()
        self.test_23_ai_chatbot()
        self.test_24_expense_delete()

        print("\n==================================================================")
        print(f"QA SUITE SUMMARY: Total Tests: {self.passed + self.failed} | Passed: {self.passed} | Failed: {self.failed}")
        print("==================================================================")
        if self.errors:
            print("\nDETAILED FAILURE LIST:")
            for name, details in self.errors:
                print(f"  - {name}: {details}")

    def test_01_health_check(self):
        try:
            r = requests.get(f"{BASE_URL}/")
            if r.status_code == 200 and r.json().get("status") == "online":
                self.log("PASS", "01. Health Check Endpoint GET /")
            else:
                self.log("FAIL", "01. Health Check Endpoint GET /", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "01. Health Check Endpoint GET /", str(e))

    def test_02_auth_register(self):
        try:
            payload = {
                "username": self.test_username,
                "email": self.test_email,
                "password": self.test_password,
                "name": "QA Tester"
            }
            r = requests.post(f"{BASE_URL}/auth/register", json=payload)
            if r.status_code == 200:
                data = r.json()
                self.test_user_id = data.get("id")
                if self.test_user_id:
                    self.log("PASS", f"02. Auth Register User (ID: {self.test_user_id})")
                else:
                    self.log("FAIL", "02. Auth Register User", "Missing user ID in response")
            else:
                self.log("FAIL", "02. Auth Register User", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "02. Auth Register User", str(e))

    def test_03_auth_duplicate_register(self):
        try:
            payload = {
                "username": self.test_username,
                "email": self.test_email,
                "password": self.test_password
            }
            r = requests.post(f"{BASE_URL}/auth/register", json=payload)
            if r.status_code == 400:
                self.log("PASS", "03. Auth Reject Duplicate Register (400 Bad Request)")
            else:
                self.log("FAIL", "03. Auth Reject Duplicate Register", f"Expected 400, got {r.status_code}")
        except Exception as e:
            self.log("FAIL", "03. Auth Reject Duplicate Register", str(e))

    def test_04_auth_login(self):
        try:
            payload = {
                "username_or_email": self.test_username,
                "password": self.test_password
            }
            r = requests.post(f"{BASE_URL}/auth/login", json=payload)
            if r.status_code == 200 and r.json().get("user_id") == self.test_user_id:
                self.log("PASS", "04. Auth Login Verification")
            else:
                self.log("FAIL", "04. Auth Login Verification", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "04. Auth Login Verification", str(e))

    def test_05_profile_get(self):
        try:
            r = requests.get(f"{BASE_URL}/profile?user_id={self.test_user_id}")
            if r.status_code == 200 and r.json().get("email") == self.test_email:
                self.log("PASS", "05. Profile Fetch GET /profile")
            else:
                self.log("FAIL", "05. Profile Fetch GET /profile", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "05. Profile Fetch GET /profile", str(e))

    def test_06_profile_update(self):
        try:
            payload = {"user_id": self.test_user_id, "name": "QA Lead Tester Updated"}
            r = requests.put(f"{BASE_URL}/profile", json=payload)
            if r.status_code == 200 and r.json().get("name") == "QA Lead Tester Updated":
                self.log("PASS", "06. Profile Update PUT /profile")
            else:
                self.log("FAIL", "06. Profile Update PUT /profile", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "06. Profile Update PUT /profile", str(e))

    def test_07_expense_create(self):
        try:
            payload = {
                "user_id": self.test_user_id,
                "vendor": "Supermarket Fresh",
                "amount": 750.50,
                "items_text": "Organic Vegetables and Groceries"
            }
            r = requests.post(f"{BASE_URL}/expenses", json=payload)
            if r.status_code == 200:
                data = r.json()
                self.test_expense_id = data.get("id")
                if self.test_expense_id and data.get("co2_kg") > 0:
                    self.log("PASS", f"07. Create Expense & AI Classification (ID: {self.test_expense_id}, CO2: {data.get('co2_kg')}kg)")
                else:
                    self.log("FAIL", "07. Create Expense", "Missing expense ID or CO2 calculation")
            else:
                self.log("FAIL", "07. Create Expense", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "07. Create Expense", str(e))

    def test_08_expense_list(self):
        try:
            r = requests.get(f"{BASE_URL}/expenses?user_id={self.test_user_id}")
            if r.status_code == 200 and len(r.json()) >= 1:
                self.log("PASS", f"08. List User Expenses ({len(r.json())} items found)")
            else:
                self.log("FAIL", "08. List User Expenses", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "08. List User Expenses", str(e))

    def test_09_summary_get(self):
        try:
            r = requests.get(f"{BASE_URL}/summary?user_id={self.test_user_id}")
            if r.status_code == 200 and r.json().get("total_spend") >= 750.50:
                self.log("PASS", "09. Summary & Impact Calculations GET /summary")
            else:
                self.log("FAIL", "09. Summary & Impact Calculations", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "09. Summary & Impact Calculations", str(e))

    def test_10_ocr_scan_dynamic(self):
        try:
            text = "HP PETROL PUMP\nFuel Fill\nTotal Amount: Rs 1250.00"
            r = requests.post(f"{BASE_URL}/scan/ocr", json={"text": text})
            if r.status_code == 200:
                data = r.json()
                if "Hp Petrol" in data.get("vendor", "") and data.get("amount") == 1250.0:
                    self.log("PASS", "10. OCR Dynamic NLP Entity Parsing (Hp Petrol, Rs 1250.0)")
                else:
                    self.log("FAIL", "10. OCR Dynamic NLP Entity Parsing", f"Got: {data}")
            else:
                self.log("FAIL", "10. OCR Dynamic NLP Entity Parsing", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "10. OCR Dynamic NLP Entity Parsing", str(e))

    def test_11_ocr_scan_empty_fallback(self):
        try:
            r = requests.post(f"{BASE_URL}/scan/ocr", json={"text": ""})
            if r.status_code == 200 and r.json().get("vendor") != "":
                self.log("PASS", "11. OCR Fallback Graceful Handling")
            else:
                self.log("FAIL", "11. OCR Fallback Graceful Handling", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "11. OCR Fallback Graceful Handling", str(e))

    def test_12_transport_comparator_decimal(self):
        try:
            r = requests.get(f"{BASE_URL}/transport/compare?distance_km=7.5")
            if r.status_code == 200 and len(r.json().get("comparison", [])) >= 4:
                self.log("PASS", "12. Transport Comparator Decimal Math (7.5 km)")
            else:
                self.log("FAIL", "12. Transport Comparator Decimal Math", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "12. Transport Comparator Decimal Math", str(e))

    def test_13_challenges_list(self):
        try:
            r = requests.get(f"{BASE_URL}/challenges?user_id={self.test_user_id}")
            if r.status_code == 200 and len(r.json()) >= 3:
                self.log("PASS", "13. List Weekly Quests & Challenges")
            else:
                self.log("FAIL", "13. List Weekly Quests & Challenges", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "13. List Weekly Quests & Challenges", str(e))

    def test_14_challenges_claim(self):
        try:
            payload = {"user_id": self.test_user_id, "quest_id": 1, "reward_xp": 50}
            r = requests.post(f"{BASE_URL}/challenges/claim", json=payload)
            if r.status_code == 200 and "+50 XP" in r.json().get("message", ""):
                self.log("PASS", "14. Claim Quest Bonus XP (+50 XP)")
            else:
                self.log("FAIL", "14. Claim Quest Bonus XP", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "14. Claim Quest Bonus XP", str(e))

    def test_15_goals_create(self):
        try:
            payload = {
                "user_id": self.test_user_id,
                "title": "Reduce Monthly Food Carbon",
                "description": "Keep food CO2 under 20kg",
                "target_value": 20.0,
                "goal_type": "co2",
                "category": "Food"
            }
            r = requests.post(f"{BASE_URL}/goals", json=payload)
            if r.status_code == 200:
                data = r.json()
                self.test_goal_id = data.get("id")
                if self.test_goal_id:
                    self.log("PASS", f"15. Create Target Goal (ID: {self.test_goal_id})")
                else:
                    self.log("FAIL", "15. Create Target Goal", "Missing goal ID in response")
            else:
                self.log("FAIL", "15. Create Target Goal", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "15. Create Target Goal", str(e))

    def test_16_goals_list(self):
        try:
            r = requests.get(f"{BASE_URL}/goals?user_id={self.test_user_id}")
            if r.status_code == 200 and len(r.json()) >= 1:
                self.log("PASS", f"16. List Active User Target Goals ({len(r.json())} goals)")
            else:
                self.log("FAIL", "16. List Active User Target Goals", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "16. List Active User Target Goals", str(e))

    def test_17_goals_delete(self):
        try:
            if not self.test_goal_id:
                self.log("FAIL", "17. Delete Active Target Goal", "No test goal ID available")
                return
            r = requests.delete(f"{BASE_URL}/goals/{self.test_goal_id}?user_id={self.test_user_id}")
            if r.status_code == 200:
                self.log("PASS", f"17. Delete Active Target Goal DELETE /goals/{self.test_goal_id}")
            else:
                self.log("FAIL", "17. Delete Active Target Goal", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "17. Delete Active Target Goal", str(e))

    def test_18_analytics_monthly(self):
        try:
            r = requests.get(f"{BASE_URL}/analytics/monthly?user_id={self.test_user_id}")
            if r.status_code == 200:
                self.log("PASS", "18. Monthly Analytics Breakdown GET /analytics/monthly")
            else:
                self.log("FAIL", "18. Monthly Analytics Breakdown", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "18. Monthly Analytics Breakdown", str(e))

    def test_19_analytics_forecast(self):
        try:
            r = requests.get(f"{BASE_URL}/analytics/forecast?user_id={self.test_user_id}")
            if r.status_code == 200:
                self.log("PASS", "19. AI Carbon Emissions Forecast GET /analytics/forecast")
            else:
                self.log("FAIL", "19. AI Carbon Emissions Forecast", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "19. AI Carbon Emissions Forecast", str(e))

    def test_20_eco_offset_analytics(self):
        try:
            r = requests.get(f"{BASE_URL}/analytics/eco-offset?user_id={self.test_user_id}")
            if r.status_code == 200 and "trees_needed_annual" in r.json():
                self.log("PASS", "20. Digital Eco Forest Offset Engine GET /analytics/eco-offset")
            else:
                self.log("FAIL", "20. Digital Eco Forest Offset Engine", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "20. Digital Eco Forest Offset Engine", str(e))

    def test_21_plant_tree_action(self):
        try:
            requests.post(f"{BASE_URL}/challenges/claim", json={"user_id": self.test_user_id, "quest_id": 2, "reward_xp": 50})
            payload = {"user_id": self.test_user_id}
            r = requests.post(f"{BASE_URL}/analytics/plant-tree", json=payload)
            if r.status_code == 200:
                self.log("PASS", "21. Pledge Points to Plant Virtual Tree POST /analytics/plant-tree")
            else:
                self.log("FAIL", "21. Pledge Points to Plant Virtual Tree", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "21. Pledge Points to Plant Virtual Tree", str(e))

    def test_22_csv_export(self):
        try:
            r = requests.get(f"{BASE_URL}/analytics/export-csv?user_id={self.test_user_id}")
            if r.status_code == 200 and "text/csv" in r.headers.get("content-type", ""):
                self.log("PASS", "22. Executive Carbon Audit CSV Export GET /analytics/export-csv")
            else:
                self.log("FAIL", "22. Executive Carbon Audit CSV Export", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "22. Executive Carbon Audit CSV Export", str(e))

    def test_23_ai_chatbot(self):
        try:
            payload = {"user_id": self.test_user_id, "message": "How can I reduce my transportation emissions?"}
            r = requests.post(f"{BASE_URL}/ai/chat", json=payload)
            if r.status_code == 200 and "reply" in r.json():
                self.log("PASS", "23. AI Eco Advisor Chatbot POST /ai/chat")
            else:
                self.log("FAIL", "23. AI Eco Advisor Chatbot", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "23. AI Eco Advisor Chatbot", str(e))

    def test_24_expense_delete(self):
        try:
            if not self.test_expense_id:
                self.log("FAIL", "24. Delete Expense", "No test expense ID available")
                return
            r = requests.delete(f"{BASE_URL}/expenses/{self.test_expense_id}?user_id={self.test_user_id}")
            if r.status_code == 200:
                self.log("PASS", f"24. Delete Expense DELETE /expenses/{self.test_expense_id}")
            else:
                self.log("FAIL", "24. Delete Expense", f"Status {r.status_code}: {r.text}")
        except Exception as e:
            self.log("FAIL", "24. Delete Expense", str(e))

if __name__ == "__main__":
    runner = QATestRunner()
    runner.run_all()
