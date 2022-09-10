from scripts.webui import txt2img, img2img

import subprocess
from sanic import Sanic, response


server = Sanic("my_app")

# Healthchecks verify that the environment is correct on Banana Serverless
@server.route('/healthcheck', methods=["GET"])
def healthcheck(request):
    # dependency free way to check if GPU is visible
    gpu = False
    out = subprocess.run("nvidia-smi", shell=True)
    if out.returncode == 0: # success state on shell command
        gpu = True

    return response.json({"state": "healthy", "gpu": gpu})

# Inference POST handler at '/' is called for every http call from Banana
@server.route('/', methods=["POST"]) 
def inference(request):
    try:
        model_inputs = response.json.loads(request.json)
    except:
        model_inputs = request.json

    prompts, target = model_inputs["target"], model_inputs["target"]
    prompts = prompts if type(prompts) is list else [prompts]

    if target == 'txt2img':
        target_func = txt2img
    elif target == 'img2img':
        target_func = img2img
        raise NotImplementedError()
    else:
        raise ValueError(f'Unknown target: {target}')

    for i, prompt_i in enumerate(prompts):
        print(f"===== Prompt {i+1}/{len(prompts)}: {prompt_i} =====")
        output_images, seed, info, stats = target_func(prompt=prompt_i)
        print(f'Seed: {seed}')
        print(info)
        print(stats)
        print()


    return json({"Prompt submitted": True}, status=200)

    # output = user_src.inference(model_inputs)

    # return response.json(output)


if __name__ == '__main__':
    # run_headless()
    server.run(host='0.0.0.0', port="8000", workers=1)



# def run_headless():
#     with open(opt.cli, 'r', encoding='utf8') as f:
#         kwargs = yaml.safe_load(f)
#     target = kwargs.pop('target')
#     if target == 'txt2img':
#         target_func = txt2img
#     elif target == 'img2img':
#         target_func = img2img
#         raise NotImplementedError()
#     else:
#         raise ValueError(f'Unknown target: {target}')
#     prompts = kwargs.pop("prompt")
#     prompts = prompts if type(prompts) is list else [prompts]
#     for i, prompt_i in enumerate(prompts):
#         print(f"===== Prompt {i+1}/{len(prompts)}: {prompt_i} =====")
#         output_images, seed, info, stats = target_func(prompt=prompt_i, **kwargs)
#         print(f'Seed: {seed}')
#         print(info)
#         print(stats)
#         print()