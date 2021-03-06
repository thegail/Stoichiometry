//
//  ReactCommand.swift
//  Stoichiometry
//
//  Created by Teddy Gaillard on 11/16/21.
//

import Foundation
import ArgumentParser

struct ReactCommand: ParsableCommand {
	static var configuration = CommandConfiguration(commandName: "react")
	
	@Argument(help: "The balanced chemical equation of the reaction") var equation: String
	
	@Flag(name: .shortAndLong, help: "Verbose mode") var verbose = false
//	@Flag(name: .shortAndLong, help: "The equation is already balanced") var balanced = false
	@Option(name: .shortAndLong, help: "Output format") var outputFormat: FormatUnit = .grams
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "Known reactants") var reactants: Array<Known> = []
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "Known products") var products: Array<Known> = []
	
	mutating func run() {
		do {
			let parsedEquation = try EquationParser.parse(self.equation)
			var measuredEquation = MeasuredEquation(equation: parsedEquation, verbose: self.verbose)
			let knownReactants = self.reactants.enumerated().filter {
				return $0.element.number != nil && $0.element.unit != nil
			}
			let knownProducts = self.products.enumerated().filter {
				return $0.element.number != nil
			}
			
			do {
				for knownReactant in knownReactants {
					switch knownReactant.element.unit! {
					case .moles:
						try measuredEquation.applyKnown(index: knownReactant.offset, reactantMoles: knownReactant.element.number!)
					case .grams:
						try measuredEquation.applyKnown(index: knownReactant.offset, reactantGrams: knownReactant.element.number!)
					case .milligrams:
						try measuredEquation.applyKnown(index: knownReactant.offset, reactantGrams: knownReactant.element.number! / 1000)
					case .liters:
						try measuredEquation.applyKnown(index: knownReactant.offset, reactantMoles: knownReactant.element.number! / 22.4)
					case .milliliters:
						try measuredEquation.applyKnown(index: knownReactant.offset, reactantMoles: knownReactant.element.number! / 22400)
					}
				}
				for knownProduct in knownProducts {
					switch knownProduct.element.unit! {
					case .moles:
						try measuredEquation.applyKnown(index: knownProduct.offset, productMoles: knownProduct.element.number!)
					case .grams:
						try measuredEquation.applyKnown(index: knownProduct.offset, productGrams: knownProduct.element.number!)
					case .milligrams:
						try measuredEquation.applyKnown(index: knownProduct.offset, productGrams: knownProduct.element.number! / 1000)
					case .liters:
						try measuredEquation.applyKnown(index: knownProduct.offset, productMoles: knownProduct.element.number! / 22.4)
					case .milliliters:
						try measuredEquation.applyKnown(index: knownProduct.offset, productMoles: knownProduct.element.number! / 22400)
					}
				}
			} catch let error {
				fatalError(error.localizedDescription)
			}
			
			print("Reaction: \(parsedEquation)")
			if !parsedEquation.isBalanced {
				print("\u{1B}[33mWarning: equation is not balanced\u{1B}[0m")
			}
			
			if self.verbose {
				Self.printMolarMasses(equation: parsedEquation)
			}
	
			try measuredEquation.fill()
			
			print("\u{1B}[1mReactants:\u{1B}[0m")
			for reactant in measuredEquation.reactants {
				guard let moles = reactant.moles else {
					fatalError("unreachable")
				}
				let massInGrams = moles * reactant.compound.molarMass
				print("\(reactant.compound) required: \(self.outputFormat.format(moles: moles, grams: massInGrams))")
			}
			
			print("\u{1B}[1mProducts:\u{1B}[0m")
			for product in measuredEquation.products {
				guard let moles = product.moles else {
					fatalError("unreachable")
				}
				let massInGrams = moles * product.compound.molarMass
				print("\(product.compound) produced: \(self.outputFormat.format(moles: moles, grams: massInGrams))")
			}
		} catch let error {
			fatalError(error.localizedDescription)
		}
	}
	
	private static func printMolarMasses(equation: Equation) {
		print("\u{1B}[1mMolar mass calculations:\u{1B}[0m")
		for unit in equation.reactants + equation.products {
			print("Molar mass of \(unit.compound) = \(unit.compound.molarMassCalculation) = \(unit.compound.molarMass) g/mol")
		}
	}
	
	struct Known: ExpressibleByArgument {
		var number: Double?
		var unit: FormatUnit?
		
		init?(argument: String) {
			if argument == "?" {
				self.number = nil
				self.unit = nil
			} else if argument.hasSuffix("g"), let number = Double(argument.prefix(argument.count - 1)) {
				self.number = number
				self.unit = .grams
			} else if argument.hasSuffix("mg"), let number = Double(argument.prefix(argument.count - 2)) {
				self.number = number
				self.unit = .milligrams
			} else if argument.hasSuffix("mol"), let number = Double(argument.prefix(argument.count - 3)) {
				self.number = number
				self.unit = .moles
			} else if argument.hasSuffix("l"), let number = Double(argument.prefix(argument.count - 1)) {
				self.number = number
				self.unit = .liters
			} else if argument.hasSuffix("ml"), let number = Double(argument.prefix(argument.count - 2)) {
				self.number = number
				self.unit = .milliliters
			} else {
				return nil
			}
		}
	}
	
	enum FormatUnit: ExpressibleByArgument {
		case moles, grams, milligrams, liters, milliliters
		
		init?(argument: String) {
			switch argument {
			case "moles", "mol", "mole":
				self = .moles
			case "grams", "g", "gram":
				self = .grams
			case "milligrams", "mg", "milligram":
				self = .milligrams
			case "liters", "l", "liter":
				self = .liters
			case "milliliters", "ml", "milliliter":
				self = .milliliters
			default:
				return nil
			}
		}
		
		func format(moles: Double, grams: Double) -> String {
			switch self {
			case .moles:
				return "\(moles) mol"
			case .grams:
				return "\(grams)g"
			case .milligrams:
				return "\(grams * 1000)mg"
			case .liters:
				return "\(moles * 22.4)l"
			case .milliliters:
				return "\(moles * 22400)ml"
			}
		}
	}
}
