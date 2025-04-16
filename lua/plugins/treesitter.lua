return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = true,

    ensure_installed = {
      "c",
      "cpp",
      "go",
      "html",
      "css",
      "odin",
      "tsx",
      "typescript",
      "javascript",
      "lua",
      "json",
      "dockerfile",
    },

    modules = {
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}
