-- Hybrid K8s YAML Configuration
-- Uses nvim-k8s-crd for schema generation + yaml-companion for LSP integration

return {
  -- Schema Store for 600+ YAML schemas
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },

  -- K8s CRD Schema Generator
  -- Generates schemas from your cluster but doesn't configure LSP
  -- (LSP configuration is handled by yaml-companion below)
  {
    "mrlunchbox777/nvim-k8s-crd",
    branch = "fix-pcall-and-config-nil",
    ft = { "yaml", "helm" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("nvim-k8s-crd").setup({
        cache_dir = "~/.cache/k8s-schemas/",
        k8s = {
          file_mask = "*.yaml",
        },
      })
      
      -- Note: This generates schemas but won't configure yamlls
      -- because we're using LazyVim's lspconfig system.
      -- yaml-companion (below) handles the LSP integration.
    end,
  },

  -- YAML Schema Detection & LSP Integration
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "b0o/SchemaStore.nvim",
    },
    ft = { "yaml", "helm" },
    config = function()
      local cfg = require("yaml-companion").setup({
        -- Built-in matchers for common file types
        builtin_matchers = {
          kubernetes = { enabled = true },
          cloud_init = { enabled = true },
        },
        
        -- Custom schemas (including K8s CRDs from nvim-k8s-crd)
        schemas = {
          -- Add your cluster schemas dynamically
          result = function()
            local schemas = {}
            
            -- Get current kubectl context
            local context = vim.fn.system("kubectl config current-context 2>/dev/null"):gsub("%s+", "")
            
            if context ~= "" then
              local schema_path = vim.fn.expand("~/.cache/k8s-schemas/" .. context .. "/all.json")
              
              -- Check if schema file exists
              if vim.fn.filereadable(schema_path) == 1 then
                table.insert(schemas, {
                  name = "Kubernetes (" .. context .. ")",
                  uri = schema_path,
                })
              end
            end
            
            return schemas
          end,
        },
        
        -- Use SchemaStore schemas as fallback
        lspconfig = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false, -- Disable built-in, use SchemaStore.nvim
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },
      })
      
      -- Configure yamlls through lspconfig
      require("lspconfig").yamlls.setup(cfg)
      
      -- Load telescope extension for schema switching
      require("telescope").load_extension("yaml_schema")
    end,
    keys = {
      {
        "<leader>cy",
        "<cmd>Telescope yaml_schema<cr>",
        desc = "YAML: Select Schema",
        ft = { "yaml", "helm" },
      },
    },
  },

  -- Override LazyVim's default yamlls config to add helm filetype
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.yamlls = opts.servers.yamlls or {}
      
      -- Ensure helm filetype is included
      local filetypes = opts.servers.yamlls.filetypes or { "yaml" }
      if not vim.tbl_contains(filetypes, "helm") then
        table.insert(filetypes, "helm")
      end
      opts.servers.yamlls.filetypes = filetypes
      
      return opts
    end,
  },
}
