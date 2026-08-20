# backend/app/classifier.py
import json
import os
import re
from typing import Tuple

BASE_DIR = os.path.dirname(__file__)
EMISSIONS_PATH = os.path.join(BASE_DIR, "emissions.json")

try:
    with open(EMISSIONS_PATH, "r", encoding="utf-8") as f:
        _EMISSIONS = json.load(f)
except Exception as e:
    print(f"Emissions load warning: {e}")
    _EMISSIONS = {
        "hints": {
            "Food & Dining": ["swiggy", "zomato", "restaurant", "food", "cafe", "hotel", "burger", "pizza", "starbucks", "mcdonalds", "diner"],
            "Transport": ["uber", "ola", "rapido", "metro", "train", "flight", "indigo", "air india", "auto", "cab", "bus", "fuel", "petrol", "diesel", "shell", "hp", "iocl", "bpcl"],
            "Groceries": ["supermarket", "mart", "grocery", "blinkit", "zepto", "instamart", "bigbasket", "reliancemart", "dmart"],
            "Shopping": ["amazon", "flipkart", "myntra", "zara", "h&m", "uniqlo", "retail", "store"],
            "Utilities": ["electricity", "power", "water", "gas", "wifi", "broadband", "recharge", "airtel", "jio"],
            "Entertainment": ["netflix", "spotify", "bookmyshow", "cinema", "movie", "prime", "youtube"]
        },
        "category_factors": {
            "Food & Dining": 0.25,
            "Transport": 0.42,
            "Fuel": 0.85,
            "Groceries": 0.18,
            "Shopping": 0.35,
            "Utilities": 0.50,
            "Entertainment": 0.15,
            "Other": 0.20
        }
    }

HINTS = _EMISSIONS.get("hints", {})
FACTORS = _EMISSIONS.get("category_factors", {})


def guess_category(vendor: str, items_text: str) -> str:
    text = f"{vendor} {items_text}".lower()
    for cat, words in HINTS.items():
        for w in words:
            if re.search(rf"\b{re.escape(w)}\b", text):
                return cat
    # Fallbacks
    if any(k in text for k in ["uber", "ola", "bus", "train", "flight", "air"]):
        return "Transport"
    if any(k in text for k in ["petrol", "diesel", "fuel", "gas"]):
        return "Fuel"
    return "Other"


def estimate_co2(amount: float, category: str) -> float:
    factor = FACTORS.get(category, FACTORS["Other"])
    return round(amount * factor / 100.0, 3)


def classify_and_estimate(vendor: str, items_text: str, amount: float) -> Tuple[str, float]:
    cat = guess_category(vendor, items_text)
    co2 = estimate_co2(amount, cat)
    return cat, co2
