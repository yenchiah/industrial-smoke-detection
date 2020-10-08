function [ sunrise_frame,sunset_frame ] = getDayIdx(date,sunrise,sunset,capture_times)
    sunrise_UTC = datetime([date,' ',sunrise],'TimeZone','UTC');
    sunset_UTC = datetime([date,' ',sunset],'TimeZone','UTC');
    if sunset_UTC<sunrise_UTC
        sunset_UTC = sunset_UTC + hours(24);
    end
    % binary search
    sunrise_frame = binarySearchDatetime(sunrise_UTC,capture_times);
    sunset_frame = binarySearchDatetime(sunset_UTC,capture_times);
end