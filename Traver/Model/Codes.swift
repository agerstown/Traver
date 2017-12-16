//
//  Codes.swift
//  Traver
//
//  Created by Natalia Nikitina on 1/22/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class Codes {
    
    enum Country: Int {
        case AE
        case AF
        case AL
        case AM
        case AO
        case AR
        case AT
        case AU
        case AZ
        case BA
        case BD
        case BE
        case BF
        case BG
        case BI
        case BJ
        case BN
        case BO
        case BR
        case BS
        case BT
        case BW
        case BY
        case BZ
        case CA
        case CD
        case CF
        case CG
        case CH
        case CI
        case CL
        case CM
        case CN
        case CO
        case CR
        case CU
        case CY
        case CZ
        case DE
        case DJ
        case DK
        case DO
        case DZ
        case EC
        case EE
        case EG
        case EH
        case ER
        case ES
        case ET
        case FK
        case FI
        case FJ
        case FR
        case GA
        case GB
        case GE
        case GF
        case GH
        case GL
        case GM
        case GN
        case GQ
        case GR
        case GT
        case GW
        case GY
        case HN
        case HR
        case HT
        case HU
        case ID
        case IE
        case IL
        case IN
        case IQ
        case IR
        case IS
        case IT
        case JM
        case JO
        case JP
        case KE
        case KG
        case KH
        case KP
        case KR
        case XK
        case KW
        case KZ
        case LA
        case LB
        case LK
        case LR
        case LS
        case LT
        case LU
        case LV
        case LY
        case MA
        case MD
        case ME
        case MG
        case MK
        case ML
        case MM
        case MN
        case MR
        case MW
        case MX
        case MY
        case MZ
        case NA
        case NC
        case NE
        case NG
        case NI
        case NL
        case NO
        case NP
        case NZ
        case OM
        case PA
        case PE
        case PG
        case PH
        case PL
        case PK
        case PR
        case PS
        case PT
        case PY
        case QA
        case RO
        case RS
        case RU
        case RW
        case SA
        case SB
        case SD
        case SE
        case SI
        case SJ
        case SK
        case SL
        case SN
        case SO
        case SR
        case SS
        case SV
        case SY
        case SZ
        case TD
        case TF
        case TG
        case TH
        case TJ
        case TL
        case TM
        case TN
        case TR
        case TT
        case TW
        case TZ
        case UA
        case UG
        case US
        case UY
        case UZ
        case VE
        case VN
        case VU
        case YE
        case ZA
        case ZM
        case ZW
        case AD
        case HK
        case SG
        case MT
        
        static let all = [AE, AF, AL, AM, AO, AR, AT, AU, AZ, BA, BD, BE, BF, BG, BI, BJ, BN, BO, BR, BS, BT, BW, BY, BZ, CA, CD, CF, CG, CH, CI, CL, CM, CN, CO, CR, CU, CY, CZ, DE, DJ, DK, DO, DZ, EC, EE, EG, EH, ER, ES, ET, FK, FI, FJ, FR, GA, GB, GE, GF, GH, GL, GM, GN, GQ, GR, GT, GW, GY, HN, HR, HT, HU, ID, IE, IL, IN, IQ, IR, IS, IT, JM, JO, JP, KE, KG, KH, KP, KR, XK, KW, KZ, LA, LB, LK, LR, LS, LT, LU, LV, LY, MA, MD, ME, MG, MK, ML, MM, MN, MR, MW, MX, MY, MZ, NA, NC, NE, NG, NI, NL, NO, NP, NZ, OM, PA, PE, PG, PH, PL, PK, PR, PS, PT, PY, QA, RO, RS, RU, RW, SA, SB, SD, SE, SI, SJ, SK, SL, SN, SO, SR, SS, SV, SY, SZ, TD, TF, TG, TH, TJ, TL, TM, TN, TR, TT, TW, TZ, UA, UG, US, UY, UZ, VE, VN, VU, YE, ZA, ZM, ZW, AD, HK, SG, MT]
        
        static let allSorted = sortCountriesByName(all)
        
        var code: String {
            return String(describing: self)
        }
        
        var name: String {
            return String(describing: self).localized()
        }
        
        private static func sortCountriesByName(_ countries: [Codes.Country]) -> [Codes.Country] {
            return countries.sorted { $0.name < $1.name }
        }
    }
    
    enum Region: Int {
        case REU
        case RAS
        case RNA
        case RSA
        case RAU
        case RAF
        
        static let all = [REU, RAS, RNA, RSA, RAU, RAF]
        
        var code: String {
            return String(describing: self)
        }
        
        var name: String {
            return String(describing: self).localized()
        }
    }
    
    static let regions: [(Region, [Country])] = [
        (.REU, sortCountriesByName([.AL, .AM, .AT, .AZ, .BY, .BE, .BA, .BG, .HR, .CY, .CZ, .DK, .EE, .FI, .FR, .GE, .DE, .GR, .GL, .HU, .IS, .IE, .IT, .KZ, .XK, .LV, .LT, .LU, .MK, .MD, .ME, .NL, .NO, .PL, .PT, .RO, .RU, .RS, .SK, .SI, .ES, .SJ, .SE, .CH, .TR, .UA, .GB, .AD, .MT])),
        (.RAS, sortCountriesByName([.AF, .BD, .BT, .BN, .KH, .CN, .IN, .ID, .IR, .IQ, .IL, .JP, .JO, .KW, .KG, .LA, .LB, .MY, .MN, .MM, .NP, .KP, .OM, .PK, .PS, .PH, .QA, .SA, .KR, .LK, .SY, .TW, .TJ, .TH, .TM, .AE, .UZ, .VN, .YE, .HK, .SG])),
        (.RNA, sortCountriesByName([.BS, .BZ, .CA, .CR, .CU, .DO, .SV, .GT, .HT, .HN, .JM, .MX, .NI, .PA, .PR, .TT, .US])),
        (.RSA, sortCountriesByName([.AR, .BO, .BR, .CL, .CO, .EC, .FK, .GF, .GY, .PY, .PE, .SR, .UY, .VE])),
        (.RAU, sortCountriesByName([.AU, .FJ, .NC, .NZ, .PG, .SB, .TL, .VU])),
        (.RAF, sortCountriesByName([.DZ, .AO, .BJ, .BW, .BF, .BI, .CM, .CF, .TD, .CD, .DJ, .EG, .GQ, .ER, .ET, .TF, .GA, .GM, .GH, .GN, .GW, .CI, .KE, .LS, .LR, .LY, .MG, .MW, .ML, .MR, .MA, .MZ, .NA, .NE, .NG, .CG, .RW, .SN, .SL, .SO, .ZA, .SS, .SD, .SZ, .TZ, .TG, .TN, .UG, .EH, .ZM, .ZW]))
    ]
    
    private static func sortCountriesByName(_ countries: [Codes.Country]) -> [Codes.Country] {
        return countries.sorted { $0.name < $1.name }
    }
    
    static let countryToRegion: [String: Codes.Region] = [
        "AL": .REU,
        "AM": .REU,
        "AT": .REU,
        "AZ": .REU,
        "BY": .REU,
        "BE": .REU,
        "BA": .REU,
        "BG": .REU,
        "HR": .REU,
        "CY": .REU,
        "CZ": .REU,
        "DK": .REU,
        "EE": .REU,
        "FI": .REU,
        "FR": .REU,
        "GE": .REU,
        "DE": .REU,
        "GR": .REU,
        "GL": .REU,
        "HU": .REU,
        "IS": .REU,
        "IE": .REU,
        "IT": .REU,
        "KZ": .REU,
        "XK": .REU,
        "LV": .REU,
        "LT": .REU,
        "LU": .REU,
        "MK": .REU,
        "MD": .REU,
        "ME": .REU,
        "NL": .REU,
        "NO": .REU,
        "PL": .REU,
        "PT": .REU,
        "RO": .REU,
        "RU": .REU,
        "RS": .REU,
        "SK": .REU,
        "SI": .REU,
        "ES": .REU,
        "SJ": .REU,
        "SE": .REU,
        "CH": .REU,
        "TR": .REU,
        "UA": .REU,
        "GB": .REU,
        "AD": .REU,
        "MT": .REU,
        "AF": .RAS,
        "BD": .RAS,
        "BT": .RAS,
        "BN": .RAS,
        "KH": .RAS,
        "CN": .RAS,
        "IN": .RAS,
        "ID": .RAS,
        "IR": .RAS,
        "IQ": .RAS,
        "IL": .RAS,
        "JP": .RAS,
        "JO": .RAS,
        "KW": .RAS,
        "KG": .RAS,
        "LA": .RAS,
        "LB": .RAS,
        "MY": .RAS,
        "MN": .RAS,
        "MM": .RAS,
        "NP": .RAS,
        "KP": .RAS,
        "OM": .RAS,
        "PK": .RAS,
        "PS": .RAS,
        "PH": .RAS,
        "QA": .RAS,
        "SA": .RAS,
        "KR": .RAS,
        "LK": .RAS,
        "SY": .RAS,
        "TW": .RAS,
        "TJ": .RAS,
        "TH": .RAS,
        "TM": .RAS,
        "AE": .RAS,
        "UZ": .RAS,
        "VN": .RAS,
        "YE": .RAS,
        "HK": .RAS,
        "SG": .RAS,
        "BS": .RNA,
        "BZ": .RNA,
        "CA": .RNA,
        "CR": .RNA,
        "CU": .RNA,
        "DO": .RNA,
        "SV": .RNA,
        "GT": .RNA,
        "HT": .RNA,
        "HN": .RNA,
        "JM": .RNA,
        "MX": .RNA,
        "NI": .RNA,
        "PA": .RNA,
        "PR": .RNA,
        "TT": .RNA,
        "US": .RNA,
        "AR": .RSA,
        "BO": .RSA,
        "BR": .RSA,
        "CL": .RSA,
        "CO": .RSA,
        "EC": .RSA,
        "FK": .RSA,
        "GF": .RSA,
        "GY": .RSA,
        "PY": .RSA,
        "PE": .RSA,
        "SR": .RSA,
        "UY": .RSA,
        "VE": .RSA,
        "AU": .RAU,
        "FJ": .RAU,
        "NC": .RAU,
        "NZ": .RAU,
        "PG": .RAU,
        "SB": .RAU,
        "TL": .RAU,
        "VU": .RAU,
        "DZ": .RAF,
        "AO": .RAF,
        "BJ": .RAF,
        "BW": .RAF,
        "BF": .RAF,
        "BI": .RAF,
        "CM": .RAF,
        "CF": .RAF,
        "TD": .RAF,
        "CD": .RAF,
        "DJ": .RAF,
        "EG": .RAF,
        "GQ": .RAF,
        "ER": .RAF,
        "ET": .RAF,
        "TF": .RAF,
        "GA": .RAF,
        "GM": .RAF,
        "GH": .RAF,
        "GN": .RAF,
        "GW": .RAF,
        "CI": .RAF,
        "KE": .RAF,
        "LS": .RAF,
        "LR": .RAF,
        "LY": .RAF,
        "MG": .RAF,
        "MW": .RAF,
        "ML": .RAF,
        "MR": .RAF,
        "MA": .RAF,
        "MZ": .RAF,
        "NA": .RAF,
        "NE": .RAF,
        "NG": .RAF,
        "CG": .RAF,
        "RW": .RAF,
        "SN": .RAF,
        "SL": .RAF,
        "SO": .RAF,
        "ZA": .RAF,
        "SS": .RAF,
        "SD": .RAF,
        "SZ": .RAF,
        "TZ": .RAF,
        "TG": .RAF,
        "TN": .RAF,
        "UG": .RAF,
        "EH": .RAF,
        "ZM": .RAF,
        "ZW": .RAF
    ]
}
