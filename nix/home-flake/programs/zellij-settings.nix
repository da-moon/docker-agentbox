{
  keybinds = {
    _props = {
      clear-defaults = true;
    };
    _children = [
      {
        locked = {
          _children = [
            {
              bind = {
                _args = [ "Alt g" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        pane = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "c" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "renamepane" ];
                    };
                  }
                  {
                    PaneNameInput = {
                      _args = [ 0 ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "d" ];
                _children = [
                  {
                    NewPane = {
                      _args = [ "down" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "e" ];
                _children = [
                  {
                    TogglePaneEmbedOrFloating = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "f" ];
                _children = [
                  {
                    ToggleFocusFullscreen = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "i" ];
                _children = [
                  {
                    TogglePanePinned = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "n" ];
                _children = [
                  {
                    NewPane = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "p" ];
                _children = [
                  {
                    SwitchFocus = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl p" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "r" ];
                _children = [
                  {
                    NewPane = {
                      _args = [ "right" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "s" ];
                _children = [
                  {
                    NewPane = {
                      _args = [ "stacked" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "w" ];
                _children = [
                  {
                    ToggleFloatingPanes = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "z" ];
                _children = [
                  {
                    TogglePaneFrames = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        tab = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    GoToPreviousTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    GoToNextTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    GoToPreviousTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    GoToNextTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "1" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 1 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "2" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 2 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "3" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 3 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "4" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 4 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "5" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 5 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "6" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 6 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "7" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 7 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "8" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 8 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "9" ];
                _children = [
                  {
                    GoToTab = {
                      _args = [ 9 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "[" ];
                _children = [
                  {
                    BreakPaneLeft = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "]" ];
                _children = [
                  {
                    BreakPaneRight = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "b" ];
                _children = [
                  {
                    BreakPane = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    GoToPreviousTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    GoToNextTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    GoToPreviousTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    GoToNextTab = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "n" ];
                _children = [
                  {
                    NewTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "r" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "renametab" ];
                    };
                  }
                  {
                    TabNameInput = {
                      _args = [ 0 ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "s" ];
                _children = [
                  {
                    ToggleActiveSyncTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl a" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "x" ];
                _children = [
                  {
                    CloseTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "tab" ];
                _children = [
                  {
                    ToggleTab = { };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        resize = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "+" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "-" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "=" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "H" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "J" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "K" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "L" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl n" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        move = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl h" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    MovePane = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "n" ];
                _children = [
                  {
                    MovePane = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "p" ];
                _children = [
                  {
                    MovePaneBackwards = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "tab" ];
                _children = [
                  {
                    MovePane = { };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        scroll = {
          _children = [
            {
              bind = {
                _args = [ "e" ];
                _children = [
                  {
                    EditScrollback = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "s" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "entersearch" ];
                    };
                  }
                  {
                    SearchInput = {
                      _args = [ 0 ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        search = {
          _children = [
            {
              bind = {
                _args = [ "c" ];
                _children = [
                  {
                    SearchToggleOption = {
                      _args = [ "CaseSensitivity" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "n" ];
                _children = [
                  {
                    Search = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "o" ];
                _children = [
                  {
                    SearchToggleOption = {
                      _args = [ "WholeWord" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "p" ];
                _children = [
                  {
                    Search = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "w" ];
                _children = [
                  {
                    SearchToggleOption = {
                      _args = [ "Wrap" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        session = {
          _children = [
            {
              bind = {
                _args = [ "a" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "zellij:about" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                      ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "c" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "configuration" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                      ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt s" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "p" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "plugin-manager" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                      ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "s" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "zellij:share" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                      ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "w" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "session-manager" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                      ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [ "locked" ];
          _children = [
            {
              bind = {
                _args = [ "Alt left" ];
                _children = [
                  {
                    MoveFocusOrTab = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt down" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt up" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt right" ];
                _children = [
                  {
                    MoveFocusOrTab = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt +" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt -" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Decrease" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt =" ];
                _children = [
                  {
                    Resize = {
                      _args = [ "Increase" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt [" ];
                _children = [
                  {
                    PreviousSwapLayout = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt ]" ];
                _children = [
                  {
                    NextSwapLayout = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt f" ];
                _children = [
                  {
                    ToggleFloatingPanes = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt g" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "locked" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt h" ];
                _children = [
                  {
                    MoveFocusOrTab = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt i" ];
                _children = [
                  {
                    MoveTab = {
                      _args = [ "left" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt j" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt k" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt l" ];
                _children = [
                  {
                    MoveFocusOrTab = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt n" ];
                _children = [
                  {
                    NewPane = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt o" ];
                _children = [
                  {
                    MoveTab = {
                      _args = [ "right" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt p" ];
                _children = [
                  {
                    TogglePaneInGroup = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt Shift p" ];
                _children = [
                  {
                    ToggleGroupMarking = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt /" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "forgot" ];
                      _children = [
                        {
                          floating = {
                            _args = [ true ];
                          };
                        }
                        {
                          move_to_focused_tab = {
                            _args = [ true ];
                          };
                        }
                        # Home Manager's KDL generator writes attribute names
                        # verbatim, so custom plugin keys must include their
                        # KDL quotes (especially keys containing spaces).
                        {
                          "\"LOAD_ZELLIJ_BINDINGS\"" = {
                            _args = [ "false" ];
                          };
                        }
                        {
                          "\"Help overlay\"" = {
                            _args = [ "Alt /" ];
                          };
                        }
                        {
                          "\"Toggle lock mode\"" = {
                            _args = [ "Alt g" ];
                          };
                        }
                        {
                          "\"Session menu\"" = {
                            _args = [ "Alt s" ];
                          };
                        }
                        {
                          "\"Tmux passthrough\"" = {
                            _args = [ "Alt t" ];
                          };
                        }
                        {
                          "\"New pane\"" = {
                            _args = [ "Alt n" ];
                          };
                        }
                        {
                          "\"Move focus\"" = {
                            _args = [ "Alt arrows" ];
                          };
                        }
                      ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl q" ];
                _children = [
                  {
                    Quit = { };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "move"
          ];
          _children = [
            {
              bind = {
                _args = [ "Ctrl h" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "move" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "session"
          ];
          _children = [
            {
              bind = {
                _args = [ "Alt s" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "session" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "scroll"
            "search"
            "tmux"
          ];
          _children = [
            {
              bind = {
                _args = [ "Alt t" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "tmux" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "scroll"
            "search"
          ];
          _children = [
            {
              bind = {
                _args = [ "Alt e" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "scroll" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "tab"
          ];
          _children = [
            {
              bind = {
                _args = [ "Ctrl a" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "tab" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "pane"
          ];
          _children = [
            {
              bind = {
                _args = [ "Ctrl p" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "pane" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "locked"
            "resize"
          ];
          _children = [
            {
              bind = {
                _args = [ "Ctrl n" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "resize" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "normal"
            "locked"
            "entersearch"
          ];
          _children = [
            {
              bind = {
                _args = [ "enter" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_except = {
          _args = [
            "normal"
            "locked"
            "entersearch"
            "renametab"
            "renamepane"
          ];
          _children = [
            {
              bind = {
                _args = [ "esc" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_among = {
          _args = [
            "pane"
            "tmux"
          ];
          _children = [
            {
              bind = {
                _args = [ "x" ];
                _children = [
                  {
                    CloseFocus = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_among = {
          _args = [
            "scroll"
            "search"
          ];
          _children = [
            {
              bind = {
                _args = [ "PageDown" ];
                _children = [
                  {
                    PageScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "PageUp" ];
                _children = [
                  {
                    PageScrollUp = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    PageScrollUp = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    ScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    ScrollUp = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    PageScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl c" ];
                _children = [
                  {
                    ScrollToBottom = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "d" ];
                _children = [
                  {
                    HalfPageScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl f" ];
                _children = [
                  {
                    PageScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    PageScrollUp = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    ScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    ScrollUp = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    PageScrollDown = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt e" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "u" ];
                _children = [
                  {
                    HalfPageScrollUp = { };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        entersearch = {
          _children = [
            {
              bind = {
                _args = [ "Ctrl c" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "scroll" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "esc" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "scroll" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "enter" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "search" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        renametab = {
          _children = [
            {
              bind = {
                _args = [ "esc" ];
                _children = [
                  {
                    UndoRenameTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "tab" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_among = {
          _args = [
            "renametab"
            "renamepane"
          ];
          _children = [
            {
              bind = {
                _args = [ "Ctrl c" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        renamepane = {
          _children = [
            {
              bind = {
                _args = [ "esc" ];
                _children = [
                  {
                    UndoRenamePane = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "pane" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        shared_among = {
          _args = [
            "session"
            "tmux"
          ];
          _children = [
            {
              bind = {
                _args = [ "d" ];
                _children = [
                  {
                    Detach = { };
                  }
                ];
              };
            }
          ];
        };
      }
      {
        tmux = {
          _children = [
            {
              bind = {
                _args = [ "left" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "left" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "down" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "up" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "right" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "right" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "space" ];
                _children = [
                  {
                    NextSwapLayout = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "\"" ];
                _children = [
                  {
                    NewPane = {
                      _args = [ "down" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "%" ];
                _children = [
                  {
                    NewPane = {
                      _args = [ "right" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "," ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "renametab" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "[" ];
                _children = [
                  {
                    SwitchToMode = {
                      _args = [ "scroll" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Alt t" ];
                _children = [
                  {
                    Write = {
                      _args = [ 2 ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "c" ];
                _children = [
                  {
                    NewTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "h" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "left" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "j" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "down" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "k" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "up" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "l" ];
                _children = [
                  {
                    MoveFocus = {
                      _args = [ "right" ];
                    };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "n" ];
                _children = [
                  {
                    GoToNextTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "o" ];
                _children = [
                  {
                    FocusNextPane = { };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "p" ];
                _children = [
                  {
                    GoToPreviousTab = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "z" ];
                _children = [
                  {
                    ToggleFocusFullscreen = { };
                  }
                  {
                    SwitchToMode = {
                      _args = [ "normal" ];
                    };
                  }
                ];
              };
            }
          ];
        };
      }
    ];
  };
  plugins = {
    _children = [
      {
        about = {
          _props = {
            location = "zellij:about";
          };
        };
      }
      {
        compact-bar = {
          _props = {
            location = "zellij:compact-bar";
          };
        };
      }
      {
        configuration = {
          _props = {
            location = "zellij:configuration";
          };
        };
      }
      {
        filepicker = {
          _props = {
            location = "zellij:strider";
          };
          _children = [
            {
              cwd = {
                _args = [ "/" ];
              };
            }
          ];
        };
      }
      {
        forgot = {
          _props = {
            location = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
          };
        };
      }
      {
        plugin-manager = {
          _props = {
            location = "zellij:plugin-manager";
          };
        };
      }
      {
        session-manager = {
          _props = {
            location = "zellij:session-manager";
          };
        };
      }
      {
        status-bar = {
          _props = {
            location = "zellij:status-bar";
          };
        };
      }
      {
        strider = {
          _props = {
            location = "zellij:strider";
          };
        };
      }
      {
        tab-bar = {
          _props = {
            location = "zellij:tab-bar";
          };
        };
      }
      {
        welcome-screen = {
          _props = {
            location = "zellij:session-manager";
          };
          _children = [
            {
              welcome_screen = {
                _args = [ true ];
              };
            }
          ];
        };
      }
    ];
  };
  load_plugins = { };
  web_client = {
    _children = [
      {
        font = {
          _args = [ "monospace" ];
        };
      }
    ];
  };
  show_startup_tips = {
    _args = [ false ];
  };
}
