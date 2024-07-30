{
  synthesizers = {
    gowin = import ./gowin.nix;
  };
  tangprimer20k = {
    family = "GW2A-18";
    device = "GW2A-LV18PG256C8/I7";
    synthesizer = "gowin";
  };
}
