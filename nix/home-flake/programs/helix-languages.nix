{
  language = [
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser"
          "markdown"
        ];
        command = "prettier";
      };
      language-servers = [ "marksman" ];
      name = "markdown";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser"
          "json"
        ];
        command = "prettier";
      };
      language-servers = [ "vscode-json-language-server" ];
      name = "json";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser=yaml"
        ];
        command = "prettier";
      };
      language-servers = [
        "yaml-language-server"
        "ansible-language-server"
      ];
      name = "yaml";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--plugin=/usr/lib/node_modules/@prettier/plugin-xml/src/plugin.js"
          "--parser=xml"
          "--single-attribute-per-line=true"
          "--xml-whitespace-sensitivity=ignore"
        ];
        command = "prettier";
      };
      language-servers = [ "gpt" ];
      name = "xml";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser=graphql"
        ];
        command = "prettier";
      };
      language-servers = [ "graphql-language-service" ];
      name = "graphql";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--binary-next-line"
          "--keep-padding"
          "--indent=2"
        ];
        command = "shfmt";
      };
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      language-servers = [ "bash-language-server" ];
      name = "bash";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--quiet"
          "-"
        ];
        command = "black";
      };
      language-servers = [ "pylsp" ];
      name = "python";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser"
          "html"
        ];
        command = "prettier";
      };
      language-servers = [ "vscode-html-language-server" ];
      name = "html";
    }
    {
      auto-format = true;
      formatter = {
        args = [
          "--print-width=79"
          "--prose-wrap=always"
          "--parser"
          "css"
        ];
        command = "prettier";
      };
      language-servers = [ "vscode-css-language-server" ];
      name = "css";
    }
    {
      language-servers = [ "awk-language-server" ];
      name = "awk";
    }
    {
      language-servers = [ "terraform-ls" ];
      name = "hcl";
    }
    {
      language-servers = [ "terraform-ls" ];
      name = "tfvars";
    }
    {
      language-servers = [ "cmake-language-server" ];
      name = "cmake";
    }
    {
      language-servers = [ "rust-analyzer" ];
      name = "rust";
    }
    {
      language-servers = [ "taplo" ];
      name = "toml";
    }
    {
      language-servers = [
        "bufls"
        "pbkit"
      ];
      name = "protobuf";
    }
    {
      language-servers = [
        "gopls"
        "golangci-lint-lsp"
      ];
      name = "go";
    }
    {
      language-servers = [ "gopls" ];
      name = "gotmpl";
    }
    {
      file-types = [ "sql" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      name = "sql";
      scope = "source.sql";
    }
    {
      auto-format = true;
      file-types = [
        "js"
        "mjs"
        "cjs"
      ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      injection-regex = "(js|javascript)";
      language-servers = [
        {
          except-features = [ "inlay-hints" ];
          name = "biome";
        }
        {
          except-features = [ "format" ];
          name = "vtsls";
        }
      ];
      name = "javascript";
      roots = [
        "package.json"
        "jsconfig.json"
        "deno.json"
        "deno.jsonc"
      ];
      scope = "source.js";
    }
    {
      auto-format = true;
      file-types = [
        "ts"
        "mts"
        "cts"
      ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      injection-regex = "(ts|typescript)";
      language-servers = [
        {
          except-features = [ "inlay-hints" ];
          name = "biome";
        }
        {
          except-features = [ "format" ];
          name = "vtsls";
        }
      ];
      name = "typescript";
      roots = [
        "package.json"
        "tsconfig.json"
        "deno.json"
        "deno.jsonc"
      ];
      scope = "source.ts";
    }
    {
      auto-format = true;
      file-types = [ "jsx" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      injection-regex = "jsx";
      language-servers = [
        {
          except-features = [ "inlay-hints" ];
          name = "biome";
        }
        {
          except-features = [ "format" ];
          name = "vtsls";
        }
      ];
      name = "jsx";
      roots = [
        "package.json"
        "jsconfig.json"
      ];
      scope = "source.jsx";
    }
    {
      auto-format = true;
      file-types = [ "tsx" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      injection-regex = "tsx";
      language-servers = [
        {
          except-features = [ "inlay-hints" ];
          name = "biome";
        }
        {
          except-features = [ "format" ];
          name = "vtsls";
        }
      ];
      name = "tsx";
      roots = [
        "package.json"
        "tsconfig.json"
      ];
      scope = "source.tsx";
    }
    {
      auto-format = true;
      file-types = [ "jsonc" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      language-servers = [ "biome" ];
      name = "jsonc";
      scope = "source.jsonc";
    }
  ];
  language-server = {
    biome = {
      args = [ "lsp-proxy" ];
      command = "biome";
    };
    rust-analyzer = {
      command = "rust-analyzer";
      config = {
        rust-analyzer = {
          trace = {
            server = "verbose";
          };
        };
      };
    };
    vtsls = {
      args = [ "--stdio" ];
      command = "vtsls";
    };
  };
}
