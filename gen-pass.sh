#!/bin/bash

perl -le 'my @chars = split("", join("", a..h, j..k, p..z, A..A, C..H, J..K, P..R, T..Y, 2..9, "!@#%&*-?+=")); print map{@chars [rand $#chars]} 0..((shift||20)-1)' $1



