---
title: "Building a Text-to-Speech (TTS) system"
tags:
  - Text-to-speech
---

Building a Text-to-Speech (TTS) system using models from Hugging Face involves selecting appropriate pre-trained models, setting up the pipeline, and generating audio from text input. Below, I’ll walk you through the detailed steps to create a TTS system using Hugging Face’s `transformers` library and other suitable tools. The process will leverage a popular TTS model like **Tacotron 2** or **VITS**, paired with a vocoder like **HiFi-GAN**, both of which are available on Hugging Face.

---

### **Overview of a TTS System**
A TTS system typically consists of:
1. **Text-to-Mel Model**: Converts text into a mel spectrogram (a representation of sound).
2. **Vocoder**: Converts the mel spectrogram into a waveform (raw audio).

Hugging Face hosts models like `facebook/tts-transformer` (based on Tacotron 2) and `facebook/hifi-gan`, which we’ll use here. Alternatively, we can use `VITS` (a single end-to-end model), which simplifies the process.

---

### **Step-by-Step Guide**

#### **Step 1: Set Up Your Environment**
- Install the required libraries:
  ```bash
  pip install transformers torch torchaudio numpy
  ```
  - `transformers`: For TTS models from Hugging Face.
  - `torch`: PyTorch backend for model computation.
  - `torchaudio`: For audio processing and saving.
  - `numpy`: For array manipulation.

- Ensure you have Python 3.8+ and a working audio setup (e.g., speakers or ability to save `.wav` files).

---

#### **Step 2: Choose a TTS Model**
For this example, we’ll use two approaches:
1. **Separate Text-to-Mel and Vocoder**: Using `facebook/tts-transformer-en-ljspeech` (Tacotron 2) + `facebook/hifi-gan`.
2. **End-to-End Model**: Using `facebook/vits-vox` (VITS, simpler but experimental).

Let’s proceed with **Option 1** for modularity, then I’ll briefly cover VITS.

---

#### **Step 3: Load the Text-to-Mel Model**
- Use `facebook/tts-transformer-en-ljspeech`, a Tacotron 2-based model trained on the LJSpeech dataset.
- **Steps**:
  1. Load the model and processor:
     ```python
     from transformers import SpeechT5Processor, SpeechT5ForTextToSpeech

     processor = SpeechT5Processor.from_pretrained("microsoft/speecht5_tts")
     model = SpeechT5ForTextToSpeech.from_pretrained("microsoft/speecht5_tts")
     ```
  2. Prepare the input text:
     ```python
     text = "Hello, this is a text-to-speech system built with Hugging Face models."
     inputs = processor(text=text, return_tensors="pt")
     ```

- **Note**: `SpeechT5` requires a speaker embedding for voice customization. We’ll use a default one from the dataset later.

---

#### **Step 4: Load the Vocoder**
- Use `facebook/hifi-gan`, a high-fidelity vocoder to convert mel spectrograms to audio.
- **Steps**:
  1. Load the vocoder:
     ```python
     from transformers import HifiGan

     vocoder = HifiGan.from_pretrained("facebook/hifi-gan")
     ```
  2. (Temporary workaround): Since `SpeechT5` and `Hifi-GAN` are not natively paired in Hugging Face’s pipeline, we’ll generate the mel spectrogram and pass it to the vocoder manually.

---

#### **Step 5: Generate Audio**
- Combine the components to produce audio:
  ```python
  import torch
  import torchaudio

  # Load speaker embeddings (example from SpeechT5 dataset)
  from datasets import load_dataset
  embeddings_dataset = load_dataset("Matthijs/cmu-arctic-xvectors", split="validation")
  speaker_embeddings = torch.tensor(embeddings_dataset[7306]["xvector"]).unsqueeze(0)

  # Generate mel spectrogram
  with torch.no_grad():
      spectrogram = model.generate_speech(inputs["input_ids"], speaker_embeddings)

  # Convert mel spectrogram to waveform using HiFi-GAN
  with torch.no_grad():
      waveform = vocoder(spectrogram)

  # Save the audio
  torchaudio.save("output.wav", waveform.unsqueeze(0), sample_rate=16000)
  print("Audio saved as 'output.wav'")
  ```

- **Explanation**:
  - `generate_speech`: Produces a mel spectrogram from text and speaker embeddings.
  - `vocoder`: Converts the spectrogram to a waveform.
  - `torchaudio.save`: Saves the audio as a `.wav` file with a 16kHz sample rate (standard for HiFi-GAN).

---

#### **Step 6: Build a TTS Pipeline**
- Wrap the process into a reusable function:
  ```python
  def text_to_speech(text, processor, model, vocoder, speaker_embeddings, output_file="output.wav"):
      # Process text
      inputs = processor(text=text, return_tensors="pt")
      
      # Generate mel spectrogram
      with torch.no_grad():
          spectrogram = model.generate_speech(inputs["input_ids"], speaker_embeddings)
      
      # Convert to waveform
      with torch.no_grad():
          waveform = vocoder(spectrogram)
      
      # Save audio
      torchaudio.save(output_file, waveform.unsqueeze(0), sample_rate=16000)
      return f"Audio saved as {output_file}"

  # Example usage
  text = "This is a test of the TTS system."
  text_to_speech(text, processor, model, vocoder, speaker_embeddings)
  ```

---

#### **Alternative: Using VITS (End-to-End)**
- VITS (`facebook/vits-vox`) is an end-to-end model that directly generates waveforms from text, skipping the separate vocoder step.
- **Steps**:
  1. Load the model:
     ```python
     from transformers import VitsModel, VitsTokenizer

     tokenizer = VitsTokenizer.from_pretrained("facebook/mms-tts-eng")
     model = VitsModel.from_pretrained("facebook/mms-tts-eng")
     ```
  2. Generate audio:
     ```python
     text = "Hello, this is VITS speaking."
     inputs = tokenizer(text, return_tensors="pt")
     with torch.no_grad():
         waveform = model(**inputs).waveform
     torchaudio.save("vits_output.wav", waveform.T, sample_rate=model.config.sampling_rate)
     print("Audio saved as 'vits_output.wav'")
     ```

- **Pros**: Simpler pipeline, single model.
- **Cons**: Fewer customization options compared to Tacotron 2 + HiFi-GAN.

---

#### **Step 7: Optimize and Deploy**
- **Optimization**:
  - Use `torch.cuda` if you have a GPU:
    ```python
    model.to("cuda")
    vocoder.to("cuda")
    inputs = {k: v.to("cuda") for k, v in inputs.items()}
    ```
  - Quantize models for faster inference with `torch.quantization`.
- **Deployment**:
  - Create a simple Flask API:
    ```python
    from flask import Flask, request

    app = Flask(__name__)

    @app.route("/tts", methods=["POST"])
    def tts():
        text = request.json["text"]
        text_to_speech(text, processor, model, vocoder, speaker_embeddings, "output.wav")
        return {"message": "Audio generated", "file": "output.wav"}

    if __name__ == "__main__":
        app.run()
    ```

---

### **Suitable Hugging Face Models**
- **Text-to-Mel**: 
  - `microsoft/speecht5_tts` (versatile, supports speaker embeddings).
  - `facebook/tts-transformer-en-ljspeech` (Tacotron 2-based).
- **Vocoder**: 
  - `facebook/hifi-gan` (high-quality audio).
- **End-to-End**: 
  - `facebook/mms-tts-eng` (VITS-based, simpler).

---

### **Additional Tips**
- **Voice Customization**: Experiment with different speaker embeddings from datasets like `cmu-arctic-xvectors`.
- **Sample Rate**: Ensure the vocoder’s sample rate matches the output (e.g., 16kHz for HiFi-GAN, 22kHz for some VITS models).
- **Quality**: Fine-tune models on custom datasets if you need a specific voice or domain.

This setup gives you a functional TTS system using Hugging Face models. Let me know if you’d like further details or help with fine-tuning!
