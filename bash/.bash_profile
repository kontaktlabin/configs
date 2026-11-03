# =====================================================================
# ~/.bash_profile - Environment Initialization (Arch Linux Only)
# =====================================================================

# # for AMD Barcelo GPU to run AI models
# export HSA_OVERRIDE_GFX_VERSION=9.0.0

[[ -f ~/.bashrc ]] && . ~/.bashrc
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
