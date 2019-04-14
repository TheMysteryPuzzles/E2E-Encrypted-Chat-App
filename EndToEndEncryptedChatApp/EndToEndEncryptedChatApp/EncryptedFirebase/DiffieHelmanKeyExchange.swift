//
//  DiffieHelmanKeyExchange.swift
//  EndToEndEncryptedChatApp
//
//  Created by Work on 4/13/19.
//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.
//

import Foundation

class DeffieHelmanKeyExchange {
    
    var MAX_LEN = 1024
    var MAXSIZE = 1000000
    var M_ITERATION =  15
    
    
    func genteratePrivateKey(p: Int) -> Int{
        return Int(arc4random_uniform(UInt32((p - 1) + 1)))
    }
    
    func GeneratePrime() -> Int {
     
        while true {
            var current_value = Int(arc4random()) % Int(Int32.max)
            if (current_value % 2) == 0 {
                current_value += 1
            }
            if MillerRabinTest(value: current_value, iteration: M_ITERATION) == 1 {
                return current_value
            }
        }
    }
    
    
    func compute_exp_modulo(primitiveRoot: Int, privateKey: Int, prime: Int) -> Int {
        var b = privateKey
        var x = 1
        var y = primitiveRoot
        while b > 0 {
            if b % 2 == 1 {
                x = Int(x * y) % prime
            }
            y = Int((y * y)) % prime
            b /= 2
        }
        return x % prime
    }
    
    
    func MillerRabinTest(value: Int, iteration: Int) -> Int {
        if value < 2 {
            return 0
        }
        print("\(value)")
        var q: Int = value - 1
        var k: Int = 0
        while q % 2 == 0 {
            q /= 2
            k += 1
        }
 
        for _ in 0..<iteration {
            let a = Int(arc4random()) % (value - 1) + 1
            let current: Int = q
            var flag: Int = 1
            var mod_result = compute_exp_modulo(primitiveRoot: a, privateKey: current, prime: value)
            if k > 1{
                for _ in 1...k {
                    if mod_result == 1 || mod_result == value - 1 {
                        flag = 0
                        break
                    }
                    mod_result = mod_result * mod_result % value
                }
            }
            if flag != 0 {
                return 0
            }
        }
        return 1
    }
    
    
    func GeneratePrimitiveRoot(p: Int) -> Int {
        
        var sieve = [Int](repeating: 0, count: MAXSIZE)
        sieve[1] = 1
        sieve[0] = sieve[1]
        var i = 4
        while i < MAXSIZE {
            sieve[i] = 1
            i += 2
        }
        i = 3
        while i < MAXSIZE {
            if sieve[i] == 0 {
                var j = 2 * i
                while j < MAXSIZE {
                    sieve[j] = 1
                    j += i
                }
            }
            i += 2
        }
        while true {
            let a = Int(arc4random()) % (p - 2) + 2
            let phi = p - 1
            var flag: Int = 1
            let root = sqrt(Double(phi))
            for i in 2...Int(root) {
                if sieve[i] == 0 && (phi % i) == 0 {
                    let mod_result = compute_exp_modulo(primitiveRoot: a, privateKey: phi / i, prime: p)
                    if mod_result == 1 {
                        flag = 0
                        break
                    }
                    if MillerRabinTest(value: phi / i, iteration: M_ITERATION) == 0 && (phi % (phi / i)) == 0 {
                        let mod_result = compute_exp_modulo(primitiveRoot: a, privateKey: phi / (phi / i), prime: p)
                        if mod_result == 1 {
                            flag = 0
                            break
                        }
                    }
                }
            }
            if flag != 0 {
                return a
            }
        }
    }
}



