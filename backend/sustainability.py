# Set of materials we consider “eco‑friendly”
ECO_FRIENDLY_MATERIALS = {
    "organic cotton",
    "cotton",
    "hemp",
    "linen",
    "recycled polyester",
    "recycled nylon",
    "tencel",
    "bamboo",
    "modal",
    "lyocell"
}

def score_sustainability(materials_list: list[dict]) -> float:
    """
    materials_list: [
      {"percentage": "60%", "material": "Cotton"},
      {"percentage": "40%", "material": "Polyester"}
    ]
    returns: float in [0..10], where 10 means 100% eco‑friendly materials
    """
    total_pct = 0.0
    eco_pct = 0.0

    for item in materials_list:
        # parse "60%" → 60.0
        perc_str = item.get("percentage", "").strip().rstrip("%")
        try:
            pct = float(perc_str)
        except ValueError:
            pct = 0.0
        total_pct += pct

        mat = item.get("material", "").lower()
        # if any eco keyword is in the material name, count it
        if any(eco in mat for eco in ECO_FRIENDLY_MATERIALS):
            eco_pct += pct

    if total_pct == 0:
        return 0.0

    # fraction of eco materials * 10 to scale 0–10
    score = (eco_pct / total_pct) * 10
    return round(score, 2)
