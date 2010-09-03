# Conversion functions between Universal Transverse Mercator (UTM) coordinate system and "normal" latitude / longitude
# The functions are specialised for the Geocentric Datum of Australia (GDA) datum

# This code has been ported to Ruby from the php code by P. Howarth and B.B. Morgan (http://nuffcumptin.com/projects/redfearn/redfearn.php)
# The php code in turn was based on an Excel spreadsheet provided by Geoscience Australia. 
# The original spreadsheet can be found at http://www.ga.gov.au/geodesy/datums/calcs.jsp  

def redfearn_ll_to_grid(latitude_degrees, longitude_degrees, ellipsoid_definition = "GRS80") 
    case ellipsoid_definition
    when "GRS80" 
        semi_major_axis = 6378137.000
        inverse_flattening = 298.257222101000
        tm_definition = "GDA-MGA"
    when "WGS84"
        semi_major_axis = 6378137.000
        inverse_flattening = 298.257223563000
        tm_definition = "GDA-MGA"
    else
        raise "unexpected value for ellipsoid_definition"
    end
     
    case tm_definition
    when "GDA-MGA" 
        false_easting = 500000.0000
        false_northing = 10000000.0000
        central_scale_factor = 0.9996
        zone_width_degrees = 6.0
        longitude_of_the_central_meridian_of_zone_1_degrees = -177.0
    else
        raise "unexpected value for tm_definition"
    end 

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
    latitude_radians = (latitude_degrees / 180) * Math::PI
    zone_no_real = (longitude_degrees - longitude_of_western_edge_of_zone_zero_degrees) / zone_width_degrees
    zone = zone_no_real.floor
    central_meridian = (zone * zone_width_degrees) + central_meridian_of_zone_zero_degrees
     
    diff_longitude_degrees =  longitude_degrees - central_meridian
    diff_longitude_radians =  (diff_longitude_degrees / 180) * Math::PI
    sin_latitude = Math::sin(latitude_radians)
    sin_latitude2 = Math::sin(2 * latitude_radians)
    sin_latitude4 = Math::sin(4 * latitude_radians)
    sin_latitude6 = Math::sin(6 * latitude_radians)
    e2 = eccentricity
    e4 = e2 ** 2
    e6 = e2 * e4
    a0 = 1 - (e2 / 4) - ((3 * e4) / 64) - ((5 * e6) / 256)
    a2 = (3.0/8) * (e2 + (e4 / 4) + ((15 * e6) / 128))
    a4 = (15.0/256) * (e4 + ((3 * e6) / 4))
    a6 = (35 * e6) / 3072
    meridian_distance_term1 = semi_major_axis * a0 * latitude_radians
    meridian_distance_term2 = -semi_major_axis * a2 * sin_latitude2
    meridian_distance_term3 = semi_major_axis * a4 * sin_latitude4
    meridian_distance_term4 = -semi_major_axis * a6 * sin_latitude6
    sum_meridian_distances = meridian_distance_term1 + meridian_distance_term2 + meridian_distance_term3 + meridian_distance_term4
    rho = semi_major_axis * (1 - e2) / ((1 - e2 * (sin_latitude ** 2)) ** 1.5)
    nu = semi_major_axis / ((1 - (e2 * (sin_latitude ** 2))) ** 0.5)
    cos_latitude1 = Math::cos(latitude_radians)
    cos_latitude2 = cos_latitude1 ** 2
    cos_latitude3 = cos_latitude1 ** 3
    cos_latitude4 = cos_latitude1 ** 4
    cos_latitude5 = cos_latitude1 ** 5
    cos_latitude6 = cos_latitude1 ** 6
    cos_latitude7 = cos_latitude1 ** 7
    diff_longitude1 = diff_longitude_radians
    diff_longitude2 = diff_longitude1 ** 2
    diff_longitude3 = diff_longitude1 ** 3
    diff_longitude4 = diff_longitude1 ** 4
    diff_longitude5 = diff_longitude1 ** 5
    diff_longitude6 = diff_longitude1 ** 6
    diff_longitude7 = diff_longitude1 ** 7
    diff_longitude8 = diff_longitude1 ** 8
    tan_latitude1 = Math::tan(latitude_radians)
    tan_latitude2 = tan_latitude1 ** 2
    tan_latitude4 = tan_latitude1 ** 4
    tan_latitude6 = tan_latitude1 ** 6
    psi1 = nu / rho
    psi2 = psi1 ** 2
    psi3 = psi1 ** 3
    psi4 = psi1 ** 4

    easting_term1 = nu * diff_longitude1 * cos_latitude1
    easting_term2 = nu * diff_longitude3 * cos_latitude3 * (psi1 - tan_latitude2) / 6
    easting_term3 = nu * diff_longitude5 * cos_latitude5 * (4 * psi3 * (1 - 6 * tan_latitude2) + psi2 * (1 + 8 * tan_latitude2) - psi1 * (2 * tan_latitude2) + tan_latitude4) / 120
    easting_term4 = nu * diff_longitude7 * cos_latitude7 * (61 - 479 *  tan_latitude2 + 179 * tan_latitude4 - tan_latitude6) / 5400

    sum_easting = easting_term1 + easting_term2 + easting_term3 + easting_term4
    sum_easting_K = central_scale_factor * sum_easting

    easting = false_easting+sum_easting_K

    northing_meridian_distance = sum_meridian_distances
    northing_term1 = nu * sin_latitude * diff_longitude2 * cos_latitude1 / 2
    northing_term2 = nu * sin_latitude * diff_longitude4 * cos_latitude3 * (4 * psi2 + psi1 - tan_latitude2) / 24
    northing_term3 = nu * sin_latitude * diff_longitude6 * cos_latitude5 * (8 * psi4 * (11 - 24 * tan_latitude2) - 28 * psi3 * (1 - 6 * tan_latitude2) + psi2 * (1 - 32 * tan_latitude2) - psi1 * (2 * tan_latitude2) + tan_latitude4) / 720
    northing_term4 =  nu * sin_latitude * diff_longitude8 * cos_latitude7 * (1385 - 3111 * tan_latitude2 + 543 * tan_latitude4 - tan_latitude6) / 40320

    sum_northing = northing_meridian_distance + northing_term1 + northing_term2 + northing_term3 + northing_term4
    sum_northing_K = central_scale_factor * sum_northing

    northing = false_northing + sum_northing_K

    grid_convergence_term1 = -sin_latitude * diff_longitude1
    grid_convergence_term2 = -sin_latitude * diff_longitude3 * cos_latitude2 * (2 * psi2 - psi1) / 3
    grid_convergence_term3 = -sin_latitude * diff_longitude5 * cos_latitude4 * (psi4 * (11 - 24 * tan_latitude2) - psi3 * (11 - 36 * tan_latitude2) + 2 * psi2 * (1 - 7 * tan_latitude2) + psi1 * tan_latitude2) / 15
    grid_convergence_term4 = sin_latitude * diff_longitude7 * cos_latitude6 * (17 - 26 * tan_latitude2 + 2 * tan_latitude4) / 315

    grid_convergence_radians = grid_convergence_term1 + grid_convergence_term2 + grid_convergence_term3 + grid_convergence_term4
    grid_convergence_degrees = (grid_convergence_radians / Math::PI) * 180
     
    point_scale_term1 = 1 + (diff_longitude2 * cos_latitude2 * psi1) / 2
    point_scale_term2 = diff_longitude4 * cos_latitude4 * (4 * psi3 * (1 - 6 * tan_latitude2) + psi2 * (1 + 24 * tan_latitude2) - 4 * psi1 * tan_latitude2) / 24
    point_scale_term3 = diff_longitude6 * cos_latitude6 * (61 - 148 * tan_latitude2 + 16 * tan_latitude4) / 720
    sum_point_scale = point_scale_term1 + point_scale_term2 + point_scale_term3
    point_scale = central_scale_factor * sum_point_scale
    
    {
        :easting => easting,
        :northing => northing,
        :zone => zone,
        :grid_convergence => grid_convergence_degrees,
        :point_scale => point_scale
    }
end

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
     
    grid_convergence_term1 = -(x1 * t1)
    grid_convergence_term2 = (t1 * x3 / 3) * (-2 * psi2 + 3 * psi1 + t2)
    grid_convergence_term3 = -(t1 * x5 / 15) * (psi4 * (11 - 24 * t2) - 3 * psi3 * (8 - 23 * t2) + 5 * psi2 * (3 - 14 * t2) + 30 * psi1 * t2 + 3 * t4)
    grid_convergence_term4 = (t1 * x7 / 315) * (17 + 77 * t2 + 105 * t4 + 45 * t6)
    grid_convergence_radians = grid_convergence_term1 + grid_convergence_term2 + grid_convergence_term3 + grid_convergence_term4
    grid_convergence_degrees = (grid_convergence_radians / Math::PI) * 180
     
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

v = {:easting => 454760.918, :northing => 6425080.861, :zone => 56}
a = redfearn_grid_to_ll(v[:easting], v[:northing], v[:zone])

p v
#p a
p redfearn_ll_to_grid(a[:latitude], a[:longitude], "GRS80")

