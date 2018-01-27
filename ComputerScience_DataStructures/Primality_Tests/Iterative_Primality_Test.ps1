function Iterative_Prime_Search ( [uint32] $x )
{
    switch ( $x )
    {
        { $x -lt 2 }      { return "{0} is not prime." -f $x }
        { $x -eq 2 }      { return "{0} is prime."     -f $x }
        { $x % 2 -eq 0 }  { return "{0} is not prime." -f $x }
        default
        {
             for ( [uint32]$i = 5; $i -le ( [Math]::Floor( [Math]::Sqrt( [double] $x ) ) );)
             {
                if ( $x % $i -eq 0 )
                {
                    return "{0} is not prime." -f $x
                }
                $i = $i + 2
             }
             return "{0} is prime." -f $x
        }
    }
}