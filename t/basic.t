use Test;
use MinG;

plan 1;

ok "+V" eq feature_from_str("+V").to_str;

done-testing;
