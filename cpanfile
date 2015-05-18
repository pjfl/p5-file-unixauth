requires "File::DataClass" => "v0.60.0";
requires "Lingua::EN::NameParse" => "1.32";
requires "Moo" => "2.000001";
requires "namespace::autoclean" => "0.22";
requires "perl" => "5.010001";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
