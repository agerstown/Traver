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
        
        static let all = [AE, AF, AL, AM, AO, AR, AT, AU, AZ, BA, BD, BE, BF, BG, BI, BJ, BN, BO, BR, BS, BT, BW, BY, BZ, CA, CD, CF, CG, CH, CI, CL, CM, CN, CO, CR, CU, CY, CZ, DE, DJ, DK, DO, DZ, EC, EE, EG, EH, ER, ES, ET, FK, FI, FJ, FR, GA, GB, GE, GF, GH, GL, GM, GN, GQ, GR, GT, GW, GY, HN, HR, HT, HU, ID, IE, IL, IN, IQ, IR, IS, IT, JM, JO, JP, KE, KG, KH, KP, KR, XK, KW, KZ, LA, LB, LK, LR, LS, LT, LU, LV, LY, MA, MD, ME, MG, MK, ML, MM, MN, MR, MW, MX, MY, MZ, NA, NC, NE, NG, NI, NL, NO, NP, NZ, OM, PA, PE, PG, PH, PL, PK, PR, PS, PT, PY, QA, RO, RS, RU, RW, SA, SB, SD, SE, SI, SJ, SK, SL, SN, SO, SR, SS, SV, SY, SZ, TD, TF, TG, TH, TJ, TL, TM, TN, TR, TT, TW, TZ, UA, UG, US, UY, UZ, VE, VN, VU, YE, ZA, ZM, ZW]
        
        var code: String {
            return String(describing: self)
        }
        
        var name: String {
            return String(describing: self).localized()
        }
    }
    
    enum Region: Int {
        case EU
        case AS
        case NA
        case SA
        case AU
        case AF
        
        var name: String {
            return String(describing: self).localized()
        }
    }
    
    static let regions: [Region: [Country]] = [
        .EU: [.AL, .AM, .AT, .AZ, .BY, .BE, .BA, .BG, .HR, .CY, .CZ, .DK, .EE, .FI, .FR, .GE, .DE, .GR, .GL, .HU, .IS, .IE, .IT, .KZ, .XK, .LV, .LT, .LU, .MK, .MD, .ME, .NL, .NO, .PL, .PT, .RO, .RU, .RS, .SK, .SI, .ES, .SJ, .SE, .CH, .TR, .UA, .GB],
        .AS: [.AF, .BD, .BT, .BN, .KH, .CN, .IN, .ID, .IR, .IQ, .IL, .JP, .JO, .KW, .KG, .LA, .LB, .MY, .MN, .MM, .NP, .KP, .OM, .PK, .PS, .PH, .QA, .SA, .KR, .LK, .SY, .TW, .TJ, .TH, .TM, .AE, .UZ, .VN, .YE],
        .NA: [.BS, .BZ, .CA, .CR, .CU, .DO, .SV, .GT, .HT, .HN, .JM, .MX, .NI, .PA, .PR, .TT, .US],
        .SA: [.AR, .BO, .BR, .CL, .CO, .EC, .FK, .GF, .GY, .PY, .PE, .SR, .UY, .VE],
        .AU: [.AU, .FJ, .NC, .NZ, .PG, .SB, .TL, .VU],
        .AF: [.DZ, .AO, .BJ, .BW, .BF, .BI, .CM, .CF, .TD, .CD, .DJ, .EG, .GQ, .ER, .ET, .TF, .GA, .GM, .GH, .GN, .GW, .CI, .KE, .LS, .LR, .LY, .MG, .MW, .ML, .MR, .MA, .MZ, .NA, .NE, .NG, .CG, .RW, .SN, .SL, .SO, .ZA, .SS, .SD, .SZ, .TZ, .TG, .TN, .UG, .EH, .ZM, .ZW]
    ]
    
    static let countryToRegion = [
        "AL": "EU",
        "AM": "EU",
        "AT": "EU",
        "AZ": "EU",
        "BY": "EU",
        "BE": "EU",
        "BA": "EU",
        "BG": "EU",
        "HR": "EU",
        "CY": "EU",
        "CZ": "EU",
        "DK": "EU",
        "EE": "EU",
        "FI": "EU",
        "FR": "EU",
        "GE": "EU",
        "DE": "EU",
        "GR": "EU",
        "GL": "EU",
        "HU": "EU",
        "IS": "EU",
        "IE": "EU",
        "IT": "EU",
        "KZ": "EU",
        "XK": "EU",
        "LV": "EU",
        "LT": "EU",
        "LU": "EU",
        "MK": "EU",
        "MD": "EU",
        "ME": "EU",
        "NL": "EU",
        "NO": "EU",
        "PL": "EU",
        "PT": "EU",
        "RO": "EU",
        "RU": "EU",
        "RS": "EU",
        "SK": "EU",
        "SI": "EU",
        "ES": "EU",
        "SJ": "EU",
        "SE": "EU",
        "CH": "EU",
        "TR": "EU",
        "UA": "EU",
        "GB": "EU",
        "AF": "AS",
        "BD": "AS",
        "BT": "AS",
        "BN": "AS",
        "KH": "AS",
        "CN": "AS",
        "IN": "AS",
        "ID": "AS",
        "IR": "AS",
        "IQ": "AS",
        "IL": "AS",
        "JP": "AS",
        "JO": "AS",
        "KW": "AS",
        "KG": "AS",
        "LA": "AS",
        "LB": "AS",
        "MY": "AS",
        "MN": "AS",
        "MM": "AS",
        "NP": "AS",
        "KP": "AS",
        "OM": "AS",
        "PK": "AS",
        "PS": "AS",
        "PH": "AS",
        "QA": "AS",
        "SA": "AS",
        "KR": "AS",
        "LK": "AS",
        "SY": "AS",
        "TW": "AS",
        "TJ": "AS",
        "TH": "AS",
        "TM": "AS",
        "AE": "AS",
        "UZ": "AS",
        "VN": "AS",
        "YE": "AS",
        "BS": "NA",
        "BZ": "NA",
        "CA": "NA",
        "CR": "NA",
        "CU": "NA",
        "DO": "NA",
        "SV": "NA",
        "GT": "NA",
        "HT": "NA",
        "HN": "NA",
        "JM": "NA",
        "MX": "NA",
        "NI": "NA",
        "PA": "NA",
        "PR": "NA",
        "TT": "NA",
        "US": "NA",
        "AR": "SA",
        "BO": "SA",
        "BR": "SA",
        "CL": "SA",
        "CO": "SA",
        "EC": "SA",
        "FK": "SA",
        "GF": "SA",
        "GY": "SA",
        "PY": "SA",
        "PE": "SA",
        "SR": "SA",
        "UY": "SA",
        "VE": "SA",
        "AU": "AU",
        "FJ": "AU",
        "NC": "AU",
        "NZ": "AU",
        "PG": "AU",
        "SB": "AU",
        "TL": "AU",
        "VU": "AU",
        "DZ": "AF",
        "AO": "AF",
        "BJ": "AF",
        "BW": "AF",
        "BF": "AF",
        "BI": "AF",
        "CM": "AF",
        "CF": "AF",
        "TD": "AF",
        "CD": "AF",
        "DJ": "AF",
        "EG": "AF",
        "GQ": "AF",
        "ER": "AF",
        "ET": "AF",
        "TF": "AF",
        "GA": "AF",
        "GM": "AF",
        "GH": "AF",
        "GN": "AF",
        "GW": "AF",
        "CI": "AF",
        "KE": "AF",
        "LS": "AF",
        "LR": "AF",
        "LY": "AF",
        "MG": "AF",
        "MW": "AF",
        "ML": "AF",
        "MR": "AF",
        "MA": "AF",
        "MZ": "AF",
        "NA": "AF",
        "NE": "AF",
        "NG": "AF",
        "CG": "AF",
        "RW": "AF",
        "SN": "AF",
        "SL": "AF",
        "SO": "AF",
        "ZA": "AF",
        "SS": "AF",
        "SD": "AF",
        "SZ": "AF",
        "TZ": "AF",
        "TG": "AF",
        "TN": "AF",
        "UG": "AF",
        "EH": "AF",
        "ZM": "AF",
        "ZW": "AF"
    ]
    
//    static let countriesAndRegions: [(Codes.Region, Codes.Country)] = [
//        (.EU, .AL),
//        (.EU, .AM),
//        (.EU, .AT),
//        (.EU, .AZ),
//        (.EU, .BY),
//        (.EU, .BE),
//        (.EU, .BA),
//        (.EU, .BG),
//        (.EU, .HR),
//        (.EU, .CY),
//        (.EU, .CZ),
//        (.EU, .DK),
//        (.EU, .EE),
//        (.EU, .FI),
//        (.EU, .FR),
//        (.EU, .GE),
//        (.EU, .DE),
//        (.EU, .GR),
//        (.EU, .GL),
//        (.EU, .HU),
//        (.EU, .IS),
//        (.EU, .IE),
//        (.EU, .IT),
//        (.EU, .KZ),
//        (.EU, .XK),
//        (.EU, .LV),
//        (.EU, .LT),
//        (.EU, .LU),
//        (.EU, .MK),
//        (.EU, .MD),
//        (.EU, .ME),
//        (.EU, .NL),
//        (.EU, .NO),
//        (.EU, .PL),
//        (.EU, .PT),
//        (.EU, .RO),
//        (.EU, .RU),
//        (.EU, .RS),
//        (.EU, .SK),
//        (.EU, .SI),
//        (.EU, .ES),
//        (.EU, .SJ),
//        (.EU, .SE),
//        (.EU, .CH),
//        (.EU, .TR),
//        (.EU, .UA),
//        (.EU, .GB),
//        (.AS, .AF),
//        (.AS, .BD),
//        (.AS, .BT),
//        (.AS, .BN),
//        (.AS, .KH),
//        (.AS, .CN),
//        (.AS, .IN),
//        (.AS, .ID),
//        (.AS, .IR),
//        (.AS, .IQ),
//        (.AS, .IL),
//        (.AS, .JP),
//        (.AS, .JO),
//        (.AS, .KW),
//        (.AS, .KG),
//        (.AS, .LA),
//        (.AS, .LB),
//        (.AS, .MY),
//        (.AS, .MN),
//        (.AS, .MM),
//        (.AS, .NP),
//        (.AS, .KP),
//        (.AS, .OM),
//        (.AS, .PK),
//        (.AS, .PS),
//        (.AS, .PH),
//        (.AS, .QA),
//        (.AS, .SA),
//        (.AS, .KR),
//        (.AS, .LK),
//        (.AS, .SY),
//        (.AS, .TW),
//        (.AS, .TJ),
//        (.AS, .TH),
//        (.AS, .TM),
//        (.AS, .AE),
//        (.AS, .UZ),
//        (.AS, .VN),
//        (.AS, .YE),
//        (.NA, .BS),
//        (.NA, .BZ),
//        (.NA, .CA),
//        (.NA, .CR),
//        (.NA, .CU),
//        (.NA, .DO),
//        (.NA, .SV),
//        (.NA, .GT),
//        (.NA, .HT),
//        (.NA, .HN),
//        (.NA, .JM),
//        (.NA, .MX),
//        (.NA, .NI),
//        (.NA, .PA),
//        (.NA, .PR),
//        (.NA, .TT),
//        (.NA, .US),
//        (.SA, .AR),
//        (.SA, .BO),
//        (.SA, .BR),
//        (.SA, .CL),
//        (.SA, .CO),
//        (.SA, .EC),
//        (.SA, .FK),
//        (.SA, .GF),
//        (.SA, .GY),
//        (.SA, .PY),
//        (.SA, .PE),
//        (.SA, .SR),
//        (.SA, .UY),
//        (.SA, .VE),
//        (.AU, .AU),
//        (.AU, .FJ),
//        (.AU, .NC),
//        (.AU, .NZ),
//        (.AU, .PG),
//        (.AU, .SB),
//        (.AU, .TL),
//        (.AU, .VU),
//        (.AF, .DZ),
//        (.AF, .AO),
//        (.AF, .BJ),
//        (.AF, .BW),
//        (.AF, .BF),
//        (.AF, .BI),
//        (.AF, .CM),
//        (.AF, .CF),
//        (.AF, .TD),
//        (.AF, .CD),
//        (.AF, .DJ),
//        (.AF, .EG),
//        (.AF, .GQ),
//        (.AF, .ER),
//        (.AF, .ET),
//        (.AF, .TF),
//        (.AF, .GA),
//        (.AF, .GM),
//        (.AF, .GH),
//        (.AF, .GN),
//        (.AF, .GW),
//        (.AF, .CI),
//        (.AF, .KE),
//        (.AF, .LS),
//        (.AF, .LR),
//        (.AF, .LY),
//        (.AF, .MG),
//        (.AF, .MW),
//        (.AF, .ML),
//        (.AF, .MR),
//        (.AF, .MA),
//        (.AF, .MZ),
//        (.AF, .NA),
//        (.AF, .NE),
//        (.AF, .NG),
//        (.AF, .CG),
//        (.AF, .RW),
//        (.AF, .SN),
//        (.AF, .SL),
//        (.AF, .SO),
//        (.AF, .ZA),
//        (.AF, .SS),
//        (.AF, .SD),
//        (.AF, .SZ),
//        (.AF, .TZ),
//        (.AF, .TG),
//        (.AF, .TN),
//        (.AF, .UG),
//        (.AF, .EH),
//        (.AF, .ZM),
//        (.AF, .ZW)
//    ]
}
