import requests

model_inputs = {'prompt': 'Hello I am a [MASK] model.', 'target': 'txt2img'}

res = requests.post('http://localhost:8000/', json = model_inputs)

print(res.json())