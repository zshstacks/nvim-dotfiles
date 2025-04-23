return {
  -- tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "gopls", -- Add gopls here
        "rust-analyzer", --rust lsp
        "clangd", --c/c++ lsp
      })
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      ---@type lspconfig.options
      servers = {
        cssls = {},
        tailwindcss = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "tailwind.config.js",
              "tailwind.config.ts",
              "package.json",
              "vite.config.ts",
              ".git"
            )(fname)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        clangd = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {},
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        -- Add the Go LSP server (gopls)
        gopls = {
          cmd = { "gopls" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("go.mod")(fname) or vim.loop.cwd()
          end,
          settings = {
            golang = {
              -- Optional settings for Go (you can add more if needed)
              lintTool = "golangci-lint",
              analyses = {
                unusedparams = true,
                unreachable = true,
              },
            },
          },
        },
        --Add the Odin lsp server(ols)
        ols = {
          cmd = { "C:/Program Files (x86)/ols-master/ols.exe", "--stdio" },
          filetypes = { "odin" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("main.odin", ".git")(fname) or vim.fn.getcwd()
          end,
          init_options = {
            checker_args = "-strict-style",
            collections = {
              { name = "shared", path = vim.fn.expand("$HOME/odin-lib") },
            },
          },
        },

        --rust
        rust_analyzer = {
          cmd = { "rust-analyzer" },
          filetypes = { "rust" },
          root_dir = require("lspconfig.util").root_pattern("Cargo.toml", "rust-project.json", ".git"),
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },

        setup = {},
      },
    },
    --ODIN
    {
      "neovim/nvim-lspconfig",
      opts = function()
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "odin",
          callback = function()
            vim.opt_local.formatprg = "C:/Program Files (x86)/ols-master/odinfmt.exe"
          end,
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      opts = function()
        local keys = require("lazyvim.plugins.lsp.keymaps").get()
        vim.list_extend(keys, {
          {
            "gd",
            function()
              -- DO NOT RESUSE WINDOW
              require("telescope.builtin").lsp_definitions({ reuse_win = false })
            end,
            desc = "Goto Definition",
            has = "definition",
          },
        })
      end,
    },
  },
}
