# Conversion functions between Universal Transverse Mercator (UTM) coordinate system and "normal" latitude / longitude
# The functions are specialised for the Geocentric Datum of Australia (GDA) datum

# This code has been ported to Ruby from the php code by P. Howarth and B.B. Morgan (http://nuffcumptin.com/projects/redfearn/redfearn.php)
# The php code in turn was based on an Excel spreadsheet provided by Geoscience Australia. 
# The original spreadsheet can be found at http://www.ga.gov.au/geodesy/datums/calcs.jsp  

# Zone values in Australia range from 49-56.
# For a rough guide to which zones relate to which areas see http://www.ga.gov.au/geodesy/datums/aboutdatums.jsp#WhatisaCoordinateSystem 
# and  
# http://www.ga.gov.au/image_cache/GA5111.gif 
 
def redfearn_grid_to_ll(easting, northing, zone)
    # These constant values are for GDA-MGA and ellipsoid definition GRS80 only
    false_easting = 500000.0000
    false_northing = 10000000.0000 
    central_scale_factor = 0.9996
    zone_width_degrees = 6.0
    longitude_of_the_central_meridian_of_zone_1_degrees = -177.0
    semi_major_axis = 6378137.000
    inverse_flattening = 298.257222101000
     
    flattening = 1 / inverse_flattening
    semi_minor_axis = semi_major_axis * (1 - flattening)
    eccentricity = (2 * flattening) - (flattening * flattening)
    n = (semi_major_axis - semi_minor_axis) / (semi_major_axis + semi_minor_axis)
    n2 = n ** 2
    n3 = n ** 3
    n4 = n ** 4
    g = semi_major_axis * (1 - n) * (1 - n2) * (1 + (9 * n2) / 4 + (225 * n4) / 64) * Math::PI / 180
    longitude_of_western_edge_of_zone_zero_degrees = longitude_of_the_central_meridian_of_zone_1_degrees - (1.5 * zone_width_degrees)
    central_meridian_of_zone_zero_degrees = longitude_of_western_edge_of_zone_zero_degrees + (zone_width_degrees / 2)
     
    new_E = (easting - false_easting)
    new_E_scaled = new_E / central_scale_factor
    new_N = (northing - false_northing)
    new_N_scaled = new_N / central_scale_factor
    sigma = (new_N_scaled * Math::PI) / (g * 180)
    sigma2 = 2 * sigma
    sigma4 = 4 * sigma
    sigma6 = 6 * sigma
    sigma8 = 8 * sigma
     
    foot_point_latitude_term1 = sigma
    foot_point_latitude_term2 = ((3 * n / 2) - (27 * n3 / 32)) * Math::sin(sigma2)
    foot_point_latitude_term3 = ((21 * n2 / 16) - (55 * n4 / 32)) * Math::sin(sigma4)
    foot_point_latitude_term4 = (151 * n3) * Math::sin(sigma6) / 96
    foot_point_latitude_term5 = 1097 * n4 * Math::sin(sigma8) / 512
    foot_point_latitude = foot_point_latitude_term1 + foot_point_latitude_term2 + foot_point_latitude_term3 + foot_point_latitude_term4 + foot_point_latitude_term5
     
    sin_foot_point_latitude = Math::sin(foot_point_latitude)
    sec_foot_point_latitude = 1 / Math::cos(foot_point_latitude)
     
    rho = semi_major_axis * (1 - eccentricity) / ((1 - eccentricity * (sin_foot_point_latitude ** 2)) ** 1.5)
    nu = semi_major_axis / ((1 - eccentricity * (sin_foot_point_latitude ** 2)) ** 0.5)
     
    x1 = new_E_scaled / nu
    x3 = x1 ** 3
    x5 = x1 ** 5
    x7 = x1 ** 7
     
    t1 = Math::tan(foot_point_latitude)
    t2 = t1 ** 2
    t4 = t1 ** 4
    t6 = t1 ** 6
     
    psi1 = nu / rho
    psi2 = psi1 ** 2
    psi3 = psi1 ** 3
    psi4 = psi1 ** 4
     
    latitude_term1 = -((t1 / (central_scale_factor * rho)) * x1 * new_E / 2)
    latitude_term2 = (t1 / (central_scale_factor * rho)) * (x3 * new_E / 24) * (-4 * psi2 + 9 * psi1 * (1 - t2) + 12 * t2)
    latitude_term3 = -(t1 / (central_scale_factor * rho)) * (x5 * new_E / 720) * (8 * psi4 * (11 - 24 * t2) - 12 * psi3 * (21 - 71 * t2) + 15 * psi2 * (15 - 98 * t2 + 15 * t4) + 180 * psi1 * (5 * t2 - 3 * t4) + 360 * t4)
    latitude_term4 = (t1 / (central_scale_factor * rho)) * (x7 * new_E / 40320) * (1385 + 3633 * t2 + 4095 * t4 + 1575 * t6)
    latitude_radians = foot_point_latitude + latitude_term1 + latitude_term2 + latitude_term3 + latitude_term4
    latitude_degrees = (latitude_radians / Math::PI) * 180
     
    central_meridian_degrees = (zone * zone_width_degrees) + longitude_of_the_central_meridian_of_zone_1_degrees - zone_width_degrees
    central_meridian_radians = (central_meridian_degrees / 180) * Math::PI
    longitude_term1 = sec_foot_point_latitude * x1
    longitude_term2 = -sec_foot_point_latitude * (x3 / 6) * (psi1 + 2 * t2)
    longitude_term3 = sec_foot_point_latitude * (x5 / 120) * (-4 * psi3 * (1 - 6 * t2) + psi2 * (9 - 68 * t2) + 72 * psi1 * t2 + 24 * t4)
    longitude_term4 = -sec_foot_point_latitude * (x7 / 5040) * (61 + 662 * t2 + 1320 * t4 + 720 * t6)
    longitude_radians = central_meridian_radians + longitude_term1 + longitude_term2 + longitude_term3 + longitude_term4
    longitude_degrees = (longitude_radians / Math::PI) * 180
     
    gridConvergenceTerm1 = -(x1 * t1)
    gridConvergenceTerm2 = (t1 * x3 / 3) * (-2 * psi2 + 3 * psi1 + t2)
    gridConvergenceTerm3 = -(t1 * x5 / 15) * (psi4 * (11 - 24 * t2) - 3 * psi3 * (8 - 23 * t2) + 5 * psi2 * (3 - 14 * t2) + 30 * psi1 * t2 + 3 * t4)
    gridConvergenceTerm4 = (t1 * x7 / 315) * (17 + 77 * t2 + 105 * t4 + 45 * t6)
    gridConvergenceRadians = gridConvergenceTerm1 + gridConvergenceTerm2 + gridConvergenceTerm3 + gridConvergenceTerm4
    grid_convergence_degrees = (gridConvergenceRadians / Math::PI) * 180
     
    point_scale_factor1 = (new_E_scaled ** 2) / (rho*nu)
    point_scale_factor2 = point_scale_factor1 ** 2
    point_scale_factor3 = point_scale_factor1 ** 3
    point_scale_term1 = 1 + point_scale_factor1 / 2
    point_scale_term2 = (point_scale_factor2 / 24) * (4 * psi1 * (1 - 6 * t2) - 3 * (1 - 16 * t2) - 24 * t2 / psi1)
    point_scale_term3 = point_scale_factor3 / 720
    point_scale = central_scale_factor * (point_scale_term1 + point_scale_term2 + point_scale_term3)
    
    {
        :latitude => latitude_degrees,
        :longitude => longitude_degrees,
        :grid_convergence => grid_convergence_degrees,
        :point_scale => point_scale
    }
end

p redfearn_grid_to_ll(454760.918, 6425080.861, 56)


