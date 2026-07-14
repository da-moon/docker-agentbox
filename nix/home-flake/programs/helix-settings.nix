{
  editor = {
    auto-pairs = false;
    auto-save = {
      enable = true;
      focus-lost = true;
    };
    bufferline = "always";
    completion-replace = true;
    continue-comments = false;
    cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };
    default-line-ending = "lf";
    end-of-line-diagnostics = "disable";
    file-picker = {
      follow-symlinks = true;
      git-ignore = true;
      hidden = false;
    };
    indent-guides = {
      render = false;
    };
    inline-diagnostics = {
      cursor-line = "disable";
      other-lines = "disable";
    };
    line-number = "relative";
    lsp = {
      display-inlay-hints = false;
      display-messages = false;
      display-progress-messages = false;
      enable = true;
    };
    shell = [
      "nu"
      "--no-config-file"
      "--no-history"
      "--no-newline"
      "--commands"
    ];
    soft-wrap = {
      enable = true;
    };
    statusline = {
      center = [
        "position"
        "position-percentage"
        "total-line-numbers"
        "file-name"
        "version-control"
      ];
      left = [
        "file-modification-indicator"
        "mode"
        "spinner"
      ];
      mode = {
        insert = "INSERT";
        normal = "NORMAL";
        select = "SELECT";
      };
      right = [
        "diagnostics"
        "file-encoding"
        "file-line-ending"
        "file-type"
      ];
      separator = "│";
    };
    text-width = 63;
    true-color = true;
    whitespace = {
      render = "all";
    };
  };
  keys = {
    insert = {
      "A-\"" = [ ":insert-output printf '\"\"'" ];
      A-' = [ ":insert-output printf \"''\"" ];
      "A-`" = [
        ":insert-output printf '```'"
        "move_char_right"
      ];
      C-down = [ "jump_view_down" ];
      C-left = [ "jump_view_left" ];
      C-right = [ "jump_view_right" ];
      C-s = [
        ":write"
        "normal_mode"
      ];
      C-up = [ "jump_view_up" ];
      tab = [ "insert_tab" ];
    };
    normal = {
      "$" = [ "goto_line_end" ];
      "+" = {
        "+" = [ ":reload" ];
        C = [ ":config-open" ];
        c = [ ":config-reload" ];
        g = {
          C = [ ":run-shell-command git commit --signoff --gpg-sign -F.git/COMMIT_EDITMSG" ];
          o = [ ":open .git/COMMIT_EDITMSG" ];
        };
        p = "@\"%P yd";
      };
      "<" = [ "goto_line_start" ];
      "=" = {
        c = {
          T = [ ":run-shell-command cargo watch -c -x 'test -- --nocapture'" ];
          t = [ ":run-shell-command cargo test -- --nocapture" ];
        };
        m = {
          ")" = [ ":run-shell-command just" ];
          "+" = [ ":run-shell-command task" ];
          ret = [ ":run-shell-command make" ];
        };
        t = {
          a = [ ":run-shell-command terraform apply -auto-approve" ];
          d = [ ":run-shell-command terraform destroy -auto-approve" ];
          i = [ ":run-shell-command terraform init" ];
        };
      };
      ">" = [ "goto_line_end" ];
      A-C = [
        ":sh echo working..."
        ":pipe-to cat > /tmp/helix-gpt"
        ":append-output cat /tmp/helix-gpt | sgpt --code --temperature 0.3 --no-cache 'Finish this code. Start typing from where I left.'"
        ":sh echo done!"
      ];
      A-b = [ "buffer_picker" ];
      A-c = [
        ":pipe sgpt --code --temperature 0.3 --no-cache 'Replace this code with a better version and complete it.'"
      ];
      A-f = [ "file_picker" ];
      A-ret = [
        ":new"
        "file_picker_in_current_directory"
      ];
      C-a = [
        "select_all"
        "select_mode"
      ];
      C-c = [
        "save_selection"
        "goto_line_start"
        "select_mode"
        "goto_line_end"
        "yank"
        "normal_mode"
        "jump_backward"
        "collapse_selection"
      ];
      C-down = [ "jump_view_down" ];
      C-f = [ "file_picker_in_current_directory" ];
      C-left = [ "jump_view_left" ];
      C-r = [ "redo" ];
      C-right = [ "jump_view_right" ];
      C-s = [ ":write!" ];
      C-up = [ "jump_view_up" ];
      C-v = [
        "save_selection"
        "goto_line_start"
        "open_above"
        "normal_mode"
        "paste_before"
        "jump_backward"
        "collapse_selection"
      ];
      C-x = [
        "goto_line_start"
        "select_mode"
        "goto_line_end"
        "yank"
        "normal_mode"
        "goto_line_start"
        "kill_to_line_end"
        "delete_char_forward"
        "collapse_selection"
      ];
      G = [ "goto_last_line" ];
      P = [ "paste_before" ];
      R = [ "replace_with_yanked" ];
      S-left = [
        "move_prev_word_start"
        "select_mode"
      ];
      S-right = [
        "move_next_word_end"
        "select_mode"
      ];
      V = [
        "goto_line_start"
        "select_mode"
        "goto_line_end"
      ];
      Y = [
        "extend_line_below"
        "yank"
      ];
      "[" = [ "unindent" ];
      "\\" = [ "toggle_comments" ];
      "]" = [ "indent" ];
      "^" = [ "goto_line_start" ];
      backspace = [
        "move_char_left"
        "select_mode"
        "delete_selection_noyank"
        "normal_mode"
      ];
      c = [ "change_selection" ];
      d = [ "delete_selection" ];
      del = [
        "select_mode"
        "delete_selection_noyank"
        "normal_mode"
        "move_char_right"
        "move_char_left"
      ];
      g = {
        "$" = [ "goto_line_end" ];
        "^" = [ "goto_line_start" ];
        q = {
          q = [
            "goto_line_start"
            "select_mode"
            "goto_line_end"
            ":reflow"
            "normal_mode"
          ];
        };
      };
      p = [ "paste_after" ];
      ret = [
        "open_below"
        "normal_mode"
      ];
      space = {
        P = [ "paste_clipboard_before" ];
        R = [ "replace_selections_with_clipboard" ];
        Y = [ "yank_main_selection_to_clipboard" ];
        j = {
          left = [ "jump_backward" ];
          ret = [ "save_selection" ];
          right = [ "jump_forward" ];
          space = [ "jumplist_picker" ];
        };
        p = [ "paste_clipboard_after" ];
        y = [ "yank_joined_to_clipboard" ];
      };
      t = {
        D = [ ":set-option file-picker.max-depth null" ];
        W = [ ":set-option whitespace.render all" ];
        d = [ ":set-option file-picker.max-depth 1" ];
        f = [
          ":toggle-option auto-format"
          ":get-option auto-format"
        ];
        g = [
          ":toggle-option file-picker.git-ignore"
          ":get-option file-picker.git-ignore"
        ];
        h = [
          ":toggle-option file-picker.hidden"
          ":get-option file-picker.hidden"
        ];
        p = [
          ":toggle-option auto-pairs"
          ":get-option auto-pairs"
        ];
        q = [
          ":toggle-option auto-pairs"
          ":get-option auto-pairs"
        ];
        t = "@:indent-style ";
        w = [ ":set-option whitespace.render none" ];
      };
      tab = [ "insert_tab" ];
      y = [ "yank" ];
      "{" = [
        ":hsplit-new"
        "file_picker_in_current_directory"
      ];
      "}" = [
        ":vsplit-new"
        "file_picker_in_current_directory"
      ];
    };
    select = {
      "$" = [ "goto_line_end" ];
      C = [
        "normal_mode"
        "yank_main_selection_to_clipboard"
      ];
      C-c = [
        "yank"
        "select_mode"
        "collapse_selection"
        "normal_mode"
      ];
      C-down = [ "jump_view_down" ];
      C-left = [ "jump_view_left" ];
      C-right = [ "jump_view_right" ];
      C-s = [
        ":write"
        "normal_mode"
      ];
      C-up = [ "jump_view_up" ];
      C-v = [
        "replace_with_yanked"
        "collapse_selection"
        "normal_mode"
      ];
      C-x = [
        "delete_selection"
        "select_mode"
        "collapse_selection"
        "normal_mode"
      ];
      S-left = [ "move_prev_word_start" ];
      S-right = [ "move_next_word_end" ];
      U = [ "switch_to_uppercase" ];
      V = [
        "replace_selections_with_clipboard"
        "collapse_selection"
        "normal_mode"
      ];
      "\\" = [
        "toggle_comments"
        "normal_mode"
      ];
      "^" = [ "goto_line_start" ];
      backspace = [ "delete_selection_noyank" ];
      u = [ "switch_to_lowercase" ];
      v = [
        "move_next_word_end"
        "normal_mode"
        "move_prev_word_start"
        "select_mode"
        "move_next_word_end"
      ];
    };
  };
  theme = "nord";
}
