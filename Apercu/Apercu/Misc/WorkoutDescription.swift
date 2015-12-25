//
//  WorkoutDescription.swift
//  Apercu
//
//  Created by David Lantrip on 12/25/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit

class WorkoutDescription {
    
    func geWorkoutDescription(workoutType: UInt) -> String {
        switch workoutType {
        case 1:
            return "American Football";
        case 2:
            return "Archery";
        case 3:
            return "Australian Football";
        case 4:
            return "Badminton";
        case 5:
            return "Baseball";
        case 6:
            return "Basketball";
        case 7:
            return "Bowling";
        case 8:
            return "Boxing";
        case 9:
            return "Climbing";
        case 10:
            return "Cricket";
        case 11:
            return "Cross Training";
        case 12:
            return "Curling";
        case 13:
            return "Cycling";
        case 14:
            return "Dance";
        case 15:
            return "Dance Inspired Training";
        case 16:
            return "Elliptical";
        case 17:
            return "Equestrian Sports";
        case 18:
            return "Fencing";
        case 19:
            return "Fishing";
        case 20:
            return "Functional Strength Training";
        case 21:
            return "Golf";
        case 22:
            return "Gymnastics";
        case 23:
            return "Handball";
        case 24:
            return "Hiking";
        case 25:
            return "Hockey";
        case 26:
            return "Hunting";
        case 27:
            return "Lacrosse";
        case 28:
            return "Martial Arts";
        case 29:
            return "Mind and Body";
        case 30:
            return "Mixed Metabolic Cardio Training";
        case 31:
            return "Paddle Sports";
        case 32:
            return "Play";
        case 33:
            return "Preparation and Recovery";
        case 34:
            return "Racquetball";
        case 35:
            return "Rowing";
        case 36:
            return "Rugby";
        case 37:
            return "Running";
        case 38:
            return "Sailing";
        case 39:
            return "Skating Sports";
        case 40:
            return "Snow Sports";
        case 41:
            return "Soccer";
        case 42:
            return "Softball";
        case 43:
            return "Squash";
        case 44:
            return "Stair Climbing";
        case 45:
            return "Surfing Sports";
        case 46:
            return "Swimming";
        case 47:
            return "Table Tennis";
        case 48:
            return "Tennis";
        case 49:
            return "Track and Field";
        case 50:
            return "Traditional Strength Training";
        case 51:
            return "Volleyball";
        case 52:
            return "Walking";
        case 53:
            return "Water Fitness";
        case 54:
            return "Water Polo";
        case 55:
            return "Water Sports";
        case 56:
            return "Wrestling";
        case 57:
            return "Yoga";
        case 3000:
            return "Other";
        default:
            return "Other";
            
        }
    }
    
}