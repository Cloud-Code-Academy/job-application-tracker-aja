public with sharing class StringUtils {
    /**
     * Removes special characters, HTML tags, and JavaScript from a string.
     * @param input The original string to sanitize.
     * @return A sanitized plain text string.
     */
    public static String sanitizeString(String input) {
        if (String.isBlank(input)) {
            return input; // Return input if it's null, empty, or whitespace.
        }
        
         // Remove HTML entities
        //String sanitized = sanitizeHtmlEntities((String) input);
        String sanitized = input.replaceAll('&nbsp;',' ');

        // Remove HTML tags using a regex
        sanitized = input.replaceAll('<[^>]*>', '');
        
        // Remove JavaScript-related patterns (e.g., <script> tags)
        sanitized = sanitized.replaceAll('(?i)<script.*?>.*?<\\/script>', '');
        
        // Remove any remaining special characters except spaces
        sanitized = sanitized.replaceAll('[^\\w\\s]', '');
        
        // Replace multiple spaces with a single space
        sanitized = sanitized.replaceAll('\\s+', ' ').trim();

        return sanitized;
    }
    private static String sanitizeHtmlEntities(String input){
        Map<String, String> htmlEntitiesMap = new Map<String,String>();
        htmlEntitiesMap.put('&nbsp;',' ');
        htmlEntitiesMap.put('&lt;','<');
        htmlEntitiesMap.put('&gt;','>');
        htmlEntitiesMap.put('&amp;','&');
        String sanitized = input;
        for(String htmlEntity : htmlEntitiesMap.keySet()){
            System.debug(sanitized);
            System.debug('htmlEntity: ' + htmlEntity);
            System.debug('value: ' + htmlEntitiesMap.get(htmlEntity));
            sanitized.replace(htmlEntity, htmlEntitiesMap.get(htmlEntity));
            System.debug('htmlEntity: ' + htmlEntity);
            System.debug('value: ' + htmlEntitiesMap.get(htmlEntity));
            System.debug(sanitized);
        }
        return sanitized;
    }
}