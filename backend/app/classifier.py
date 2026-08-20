# backend/app/classifier.py
import json
import os
import re
from typing import Tuple

BASE_DIR = os.path.dirname(__file__)
EMISSIONS_PATH = os.path.join(BASE_DIR, "emissions.json")

with open(EMISSIONS_PATH, "r", encoding="utf-8") as f:
    _EMISSIONS = json.load(f)

HINTS = _EMISSIONS["hints"]
FACTORS = _EMISSIONS["category_factors"]


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
