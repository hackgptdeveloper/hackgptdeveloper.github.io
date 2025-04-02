---
title: "Hugging Face for video generation"
tags:
  - text2video
---

Hugging Face offers a variety of open-source models and tools for video generation, primarily through its Diffusers library, which supports tasks like text-to-video and image-to-video generation. Below are some of the key options available as of April 2, 2025, based on the latest developments in the ecosystem:

### 1. **Stable Video Diffusion (SVD)**
   - **Type**: Image-to-Video
   - **Description**: Developed by Stability AI, this model generates short, high-quality videos from a single conditioning image. It’s based on Stable Diffusion 2.1 and uses a three-stage training process (images, low-res videos, high-res videos).
   - **Key Features**:
     - Supports micro-conditioning parameters like `motion_bucket_id` (controls motion intensity) and `noise_aug_strength` (adjusts deviation from the input image).
     - Customizable frame rates and video length via the `num_frames` parameter.
   - **Usage Example**:
     ```python
     from diffusers import StableVideoDiffusionPipeline
     from diffusers.utils import load_image, export_to_video
     import torch

     pipeline = StableVideoDiffusionPipeline.from_pretrained("stabilityai/stable-video-diffusion-img2vid", torch_dtype=torch.float16)
     pipeline.enable_model_cpu_offload()
     image = load_image("path/to/image.png").resize((1024, 576))
     frames = pipeline(image, num_frames=25, generator=torch.manual_seed(42)).frames[0]
     export_to_video(frames, "output.mp4", fps=7)
     ```
   - **Best For**: Generating smooth video sequences from static images with control over motion.

### 2. **CogVideoX**
   - **Type**: Text-to-Video and Image-to-Video
   - **Description**: A multidimensional transformer model by THUDM that integrates text, time, and space for video generation. It uses a 3D Variational Autoencoder (VAE) for spatial-temporal compression and supports both text and image inputs.
   - **Variants**:
     - `THUDM/CogVideoX-5b`: Text-to-video (5 billion parameters).
     - `THUDM/CogVideoX-5b-I2V`: Image-to-video.
   - **Key Features**:
     - High alignment with text prompts via adjustable `guidance_scale`.
     - Memory optimization options like VAE tiling and slicing.
     - Generates up to 49 frames (around 6 seconds at 8 fps).
   - **Usage Example** (Image-to-Video):
     ```python
     from diffusers import CogVideoXImageToVideoPipeline
     from diffusers.utils import export_to_video, load_image
     import torch

     pipe = CogVideoXImageToVideoPipeline.from_pretrained("THUDM/CogVideoX-5b-I2V", torch_dtype=torch.bfloat16)
     pipe.vae.enable_tiling()
     image = load_image("path/to/image.png")
     prompt = "A rocket soaring through a starry sky."
     video = pipe(prompt, image, num_frames=49, guidance_scale=6).frames[0]
     export_to_video(video, "output.mp4", fps=8)
     ```
   - **Best For**: Creative video generation with detailed text or image prompts.

### 3. **HunyuanVideo**
   - **Type**: Text-to-Video
   - **Description**: An advanced open-source model by Tencent with over 13 billion parameters, making it one of the largest available. It’s designed for high visual quality, motion diversity, and text-video alignment.
   - **Key Features**:
     - Outperforms some closed-source models like Runway Gen-3 and Luma 1.6 in human evaluations.
     - Supports parallel inference with xDiT for efficiency (requires significant VRAM, e.g., 60GB+ for 720p, 129 frames).
     - FP8 quantized weights available to reduce memory usage by ~10GB.
   - **Usage**: Integrated into Diffusers as of December 2024; inference code is available on Hugging Face.
   - **Best For**: High-quality, large-scale video generation for research or professional use.

### 4. **ModelScope Text-to-Video (TTV)**
   - **Type**: Text-to-Video
   - **Description**: A diffusion-based model with 1.7 billion parameters, focused on generating videos from English text prompts. It uses a UNet3D structure for iterative denoising.
   - **Key Features**:
     - Simple to use with minimal setup.
     - Optimized for memory with options like attention slicing and Torch 2.0.
     - Limited to short clips (e.g., 2-25 seconds).
   - **Usage Example**:
     ```python
     from diffusers import DiffusionPipeline
     from diffusers.utils import export_to_video
     import torch

     pipe = DiffusionPipeline.from_pretrained("damo-vilab/text-to-video-ms-1.7b", torch_dtype=torch.float16)
     pipe.enable_model_cpu_offload()
     prompt = "A dog running in a park."
     video_frames = pipe(prompt, num_inference_steps=25).frames
     export_to_video(video_frames, "output.mp4")
     ```
   - **Best For**: Quick prototyping and experimentation with text-to-video.

### 5. **I2VGen-XL**
   - **Type**: Image-to-Video
   - **Description**: A high-quality image-to-video model by Ali-Vilab, built on diffusion techniques, suitable for generating detailed video sequences from images.
   - **Key Features**:
     - Supports negative prompts to avoid unwanted elements (e.g., "blurry, low resolution").
     - Adjustable `guidance_scale` for creative control.
   - **Usage Example**:
     ```python
     from diffusers import I2VGenXLPipeline
     from diffusers.utils import export_to_gif, load_image
     import torch

     pipeline = I2VGenXLPipeline.from_pretrained("ali-vilab/i2vgen-xl", torch_dtype=torch.float16)
     pipeline.enable_model_cpu_offload()
     image = load_image("path/to/image.png").convert("RGB")
     prompt = "A car driving through a forest."
     frames = pipeline(prompt, image, num_inference_steps=50, guidance_scale=1.0).frames[0]
     export_to_gif(frames, "output.gif")
     ```
   - **Best For**: Detailed image-to-video transitions with text guidance.

### 6. **AnimateDiff**
   - **Type**: Text-to-Video (Personalized Animation)
   - **Description**: Inserts a motion modeling module into a frozen text-to-image model to create animated sequences, often used for stylized or personalized outputs.
   - **Key Features**:
     - Lightweight compared to fully pretrained video models.
     - Ideal for generating short animated clips or GIFs.
   - **Best For**: Artistic or animated video content from text prompts.

### Additional Tools and Considerations
- **Diffusers Library**: Most of these models are accessible via the Diffusers library, which provides pipelines for easy inference, memory optimization (e.g., `enable_model_cpu_offload()`), and customization (e.g., adjusting `num_inference_steps` or `guidance_scale`).
- **Hardware Requirements**: Video generation is memory-intensive. Models like HunyuanVideo require substantial VRAM (60GB+), while others like ModelScope or SVD can run on less (e.g., 8-16GB with optimizations).
- **Community Spaces**: Hugging Face hosts Spaces (e.g., ModelScope Text-to-Video Synthesis by ali-vilab) where you can test models interactively without local setup.
- **Emerging Models**: Newer models like SketchVideo (for sketch-based generation/editing) and VideoCrafter1 have appeared recently, expanding the range of creative options.

### How to Choose?
- **Text-to-Video**: Use CogVideoX, HunyuanVideo, or ModelScope TTV for direct text input.
- **Image-to-Video**: Opt for Stable Video Diffusion, CogVideoX-I2V, or I2VGen-XL for image-based generation.
- **Creative/Artistic**: AnimateDiff or smaller models like Hotshot-XL (for GIFs) are great for stylized outputs.
- **High-Quality/Research**: HunyuanVideo stands out for its scale and performance.

These options reflect the state of video generation on Hugging Face as of early 2025, with ongoing updates likely to introduce even more capabilities. For the latest models, check the Hugging Face Hub under the "Text-to-Video" or "Image-to-Video" filters!
