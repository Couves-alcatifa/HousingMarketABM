
import requests
from bs4 import BeautifulSoup

def adjust_value(value, from_year, from_month, to_year, to_month):
    url = f"https://www.ine.pt/ine/ipc/ipc_t.jsp"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    }
    values = {
        "opc1": "02", # 02 is the option for the consumer price index (without housing)
        "opc_moeda": "Euros",
        "ano_inic": str(from_year),
        "mes_inic": str(from_month),
        "valor_act_a": str(value),
        "ano_fim": str(to_year),
        "mes_fim": str(to_month),
        # "x": "39",
        # "y": "7",
    }
    response = requests.post(url, headers=headers, data=values)
    soup = BeautifulSoup(response.content, 'html.parser')

    # Extract the adjusted value that is in the tag  <input name="v_actualizado"
    soup = soup.find("input", {"name": "v_actualizado"})
    adjusted_value = soup["value"]
    adjusted_value = adjusted_value.replace(",", ".")
    adjusted_value = float(adjusted_value)
    return adjusted_value

# Example usage
original_value = 100  # Example value in January 2021
# convert string to float where the string uses a comma as decimal separator
adjusted_value = adjust_value(original_value, 2021, 1, 2011, 1)

# print(f"Adjusted value: {adjusted_value}")