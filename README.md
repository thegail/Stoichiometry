# Stoichiometry

Stoichiometry is a powerful command line tool for performing stoichiometry
chemicals and chemical equations. Its subcommands are listed below. @MDNich
has built a GUI frontend for this tool, along with a collection of other
helpful science utilities at [MDNich/SciTool](https://github.com/MDNich/SciTool)

## React

The React subcommand performs limiting factor calculations on a chemical
equation to calculate the exact amounts of reactants required and products
produced. It takes one argument, `equation`, which is a textual
representation of the balanced chemical reaction in the form
```
Na2(CO3) + CaCl2 -> Ca(CO3) + 2NaCl 
```
Where `Na2(CO3)` and `CaCl2` are reactants, and `Ca(CO3)` and `NaCl` are
products.

You must also provide at least one target argument. When targeting an
amount of either a reactant or product, you use the `--reactants` (`-r`)
and `--products` (`-p`) options respectively, adding either a ?
(no target) or a number representing the targeted amount of each
reactant/product annotated with a unit (grams, milligrams, moles supported).
This example `react` command calculates the required amounts of sodium
carbonate and calcium chloride to produce 2 grams of calcium carbonate:
```
$ stoic react "Na2(CO3) + CaCl2 -> Ca(CO3) + 2NaCl" --products 2g ?
Reaction: Na2(CO3) + CaCl2 -> Ca(CO3) + 2NaCl
Reactants:
Na2(CO3) required: 2.117920887633085g
CaCl2 required: 2.2176519487163096g
Products:
Ca(CO3) produced: 2.0g
NaCl produced: 2.335572836349394g
```

The `--verbose` (`-v`) flag enables verbose output, which prints the detailed molar mass
calculations for each compound and the limiting reaction calculation. Here
is the output of the previous example with the verbose flag enabled:
 
```
$ stoic react "Na2(CO3) + CaCl2 -> Ca(CO3) + 2NaCl" --products 2 ? --verbose
Reaction: Na2(CO3) + CaCl2 -> Ca(CO3) + 2NaCl
Molar mass calculations:
Molar mass of Na2(CO3) = 2x22.989769282 + (12.011 + 3x15.999) = 105.987538564 g/mol
Molar mass of CaCl2 = 40.0784 + 2x35.45 = 110.97840000000001 g/mol
Molar mass of Ca(CO3) = 40.0784 + (12.011 + 3x15.999) = 100.0864 g/mol
Molar mass of NaCl = 22.989769282 + 35.45 = 58.439769282 g/mol
Limiting factor calculation:
Number of reactions to produce 0.019982734917031685 mol of Ca(CO3): 0.019982734917031685
Limiting factor: Ca(CO3) (0.019982734917031685 reactions occurring)
0.019982734917031685 mol Na2(CO3) used
0.019982734917031685 mol CaCl2 used
0.019982734917031685 mol Ca(CO3) produced
0.03996546983406337 mol NaCl produced
Reactants:
Na2(CO3) required: 2.117920887633085g
CaCl2 required: 2.2176519487163096g
Products:
Ca(CO3) produced: 2.0g
NaCl produced: 2.335572836349394g
```

The `--output-format` option (`-o`) changes the output units,
if you want to view the reactant/product amounts in another format.
Supported formats are grams, milligrams, and moles.

## Mass

The Mass subcommand calculates the molar mass of a compound, and provides
options to automatically convert grams to moles or vice versa. It takes
one argument, `compound`, which is the chemical formula for the compound
you want the mass of. The `--grams` option (`-g`) uses the molar mass of
the compound to convert grams of that compound to moles, and the `--moles`
option (`-m`) does the reverse. This example `mass` command calculates the
number of moles in 23.5 grams of copper (II) chloride:
```
$ stoic mass "CuCl2" --grams 23.5
23.5 grams of CuCl2 = 0.1747909760253722 mol
```

The `--verbose` option (`-v`) includes the detailed molar mass calculation
in the output. The above command with the `--verbose` option outputs:
```
$ stoic mass "CuCl2" --grams 23.5 --verbose
Molar mass of CuCl2 = 63.5463 + 2x35.45 = 134.4463 g/mol
23.5 grams of CuCl2 = 0.1747909760253722 mol
```
