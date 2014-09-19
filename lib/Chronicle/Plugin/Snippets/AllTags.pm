
package Chronicle::Plugin::Snippets::AllTags;

use strict;
use warnings;




=begin doc

Generate the global variable 'all_tags' which can be used in the side-bar,
etc.

=end doc

=cut

sub on_initiate
{
    my ( $self, $config, $dbh ) = (@_);

    #
    # Get the tags, and their count.
    #
    my $sql = $dbh->prepare(
        'SELECT DISTINCT(name),COUNT(name) AS runningtotal FROM tags GROUP BY name ORDER BY name'
      ) or
      die "Failed to prepare tag cloud";
    $sql->execute() or die "Failed to execute: " . $dbh->errstr();

    my ( $tag, $count );
    $sql->bind_columns( undef, \$tag, \$count );

    my $tags;

    #
    # Process the results.
    #
    while ( $sql->fetch() )
    {
        my $size = $count * 5 + 5;
        if ( $size > 60 ) {$size = 60;}

        push( @$tags,
              {  tag   => $tag,
                 count => $count,
                 tsize => $size
              } );

    }
    $sql->finish();


    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "all_tags" } = $tags if ($tags);
}


=begin doc

Ensure we get called early.

=end doc

=cut

sub on_initiate_order
{
    return 0;
}


1;




