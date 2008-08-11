package MyCRUD::Main;
use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_classes(qw/Album Song/);

1;
