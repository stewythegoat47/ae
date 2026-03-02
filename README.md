# 🤖 ae - Simple AI Coding Agents Side-by-Side

[![Download ae](https://img.shields.io/badge/Download%20ae-Open%20GitHub%20Page-brightgreen?style=for-the-badge)](https://github.com/stewythegoat47/ae)

## 📋 What is ae?

ae is a simple program that lets you run multiple AI coding helpers side-by-side in your terminal. It uses a tool called tmux, which splits your screen into sections. This way, you can work with several AI assistants at the same time and see everything clearly.

You don’t need to know coding to use ae. It's designed to be easy to set up and use, so you can focus on your projects and get help from AI without any fuss.

## 🎯 Why use ae?

- Run many AI agents in one screen.
- Work faster with AI coding help.
- Keep your terminal neat and organized.
- Focus on your code without opening many windows.

## 💻 System Requirements

To use ae, your computer needs:

- A recent version of Linux or macOS. Windows users can try using the Windows Subsystem for Linux (WSL).
- tmux installed (a terminal multiplexer).
- A command-line interface (Terminal on macOS/Linux, WSL or similar on Windows).
- Basic internet connection for AI agents to work.

## 🛠 Features

- Multiple AI agents running side by side.
- Simple command-line setup.
- Organized window panels with tmux.
- Supports AI models like Claude and Codex.
- Works with bash commands and coding assistants.
- Helps with pair programming and developer tasks.

## 🚀 Getting Started

Here is a step-by-step guide to get ae running on your computer.

### 1. Download ae

Click the big green badge at the top or visit this page to download and learn more:

[Download ae on GitHub](https://github.com/stewythegoat47/ae)

You will find all the files and instructions there.

### 2. Install tmux

ae requires tmux to work because it splits your screen into multiple panels.

Open your terminal and type:

- For Ubuntu or Debian:
  ```
  sudo apt update
  sudo apt install tmux
  ```

- For macOS (using Homebrew):
  ```
  brew install tmux
  ```

- For Windows users using WSL:
  ```
  sudo apt update
  sudo apt install tmux
  ```

If you already have tmux, you can check by typing:
```
tmux -V
```
It should print the tmux version.

### 3. Download ae files to your computer

You can download the entire project as a ZIP file from GitHub if you do not want to use git:

- Go to the [ae GitHub page](https://github.com/stewythegoat47/ae).
- Find the green button labeled **Code**.
- Click **Download ZIP**.
- Save the ZIP file somewhere easy to find.
- Unzip the file.

Alternatively, if you have git installed, open your terminal and type:
```
git clone https://github.com/stewythegoat47/ae.git
```
This downloads ae into a folder named "ae".

### 4. Open ae folder

In your terminal, navigate to the folder where you downloaded or unzipped ae. For example:
```
cd ae
```

### 5. Run the program

Start tmux and run ae by typing the command:
```
bash run.sh
```

This script will launch multiple AI coding agents in different tmux panes. You will see the screen split, each panel showing a different AI assistant’s output.

### 6. How to use the AI agents in ae

- Each pane runs a different AI coding helper.
- You can type commands or questions to the AI in each pane.
- Use tmux shortcuts to switch between panes easily (usually `Ctrl+b` then arrow keys).
- Get coding suggestions, fixes, or help from each AI side-by-side.
- Use it for coding projects, learning, or exploring AI help.

## 📥 Download & Install ae

You can download ae by visiting this GitHub page:

[Download ae on GitHub](https://github.com/stewythegoat47/ae)

Once downloaded, follow these steps:

1. Make sure tmux is installed on your computer.
2. Unpack the ae files if you downloaded a ZIP.
3. Open your terminal and navigate to the ae folder.
4. Run the command `bash run.sh` to launch the multi-agent environment.

If you run into any trouble, check the Troubleshooting section below.

## ⚙️ Configuration (Optional)

You can customize which AI agents run and how many screens you want.

- Edit the `run.sh` file using a text editor.
- Add or remove AI commands as needed.
- Change the number of panes tmux opens by adjusting the tmux commands.

This lets you tailor ae to work the way you prefer.

## 📝 Troubleshooting

- **tmux not found:** Make sure tmux is installed and the terminal session is restarted.
- **run.sh permission denied:** Run `chmod +x run.sh` to make the file executable.
- **AI outputs not loading:** Check your internet connection.
- **Unsure how to switch panes:** Press `Ctrl+b` together, release, then press arrow keys to move between panes.

## 👥 Getting Help

If you need support:

- Visit the [Issues](https://github.com/stewythegoat47/ae/issues) page on GitHub to ask questions or report bugs.
- Read through any documentation or notes in the GitHub repository.

## 🧰 Tools and Technologies Used

- **tmux:** A terminal workspace tool that lets you use split windows.
- **AI Agents:** Powered by AI models like Claude and Codex.
- **Bash Scripts:** To manage and run the AI agents easily.

## 📚 Learn More

To understand what tmux is and how to use it, visit:
- https://github.com/tmux/tmux/wiki

AI models like Claude and Codex are behind-the-scenes helpers that understand and write code based on your input.

---

Thank you for choosing ae. Enjoy coding smarter with multiple AI agents ready to assist you in one place.