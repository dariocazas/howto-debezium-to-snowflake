import java.lang.Double;
import java.lang.Integer;
import java.lang.Long;
import java.lang.Math;
import java.lang.StringBuilder;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class RandomGenerator {

    final static int MAX_LOW_ID = 4;
    final static int MAX_HIGH_ID = 10;
    final static Random RANDOM = new Random();
    final static List<String> femaleNames = Arrays.asList("Hana", "Zoya", "Willie", "Nettie", "Kara", "Lara", "Halima", "Laila", "Alicia", "Caroline");
    final static List<String> maleNames = Arrays.asList("Morgan", "Abraham", "John", "Bruce", "Floyd", "Timothy", "Hussain", "Jackson", "Shane", "Shaun");
    final static List<String> names = Stream.concat(femaleNames.stream(), maleNames.stream()).collect(Collectors.toList());
    final static List<String> countries = Arrays.asList("Afghanistan","Albania","Algeria","Andorra","Angola","Anguilla","Antigua &amp; Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnia &amp; Herzegovina","Botswana","Brazil","British Virgin Islands","Brunei","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Cape Verde","Cayman Islands","Chad","Chile","China","Colombia","Congo","Cook Islands","Costa Rica","Cote D Ivoire","Croatia","Cruise Ship","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Estonia","Ethiopia","Falkland Islands","Faroe Islands","Fiji","Finland","France","French Polynesia","French West Indies","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guam","Guatemala","Guernsey","Guinea","Guinea Bissau","Guyana","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kuwait","Kyrgyz Republic","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macau","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Namibia","Nepal","Netherlands","Netherlands Antilles","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Reunion","Romania","Russia","Rwanda","Saint Pierre &amp; Miquelon","Samoa","San Marino","Satellite","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","South Africa","South Korea","Spain","Sri Lanka","St Kitts &amp; Nevis","St Lucia","St Vincent","St. Lucia","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor LEste","Togo","Tonga","Trinidad &amp; Tobago","Tunisia","Turkey","Turkmenistan","Turks &amp; Caicos","Uganda","Ukraine","United Arab Emirates","United Kingdom","Uruguay","Uzbekistan","Venezuela","Vietnam","Virgin Islands (US)","Yemen","Zambia","Zimbabwe");
    final static List<String> products = Arrays.asList("Computers", "Mobile phones", "Entertainment equipment, such as an Xbox or PlayStation", "Household furniture", "Washing machines and dishwashers", "Clothing", "Sports equipment", "Kitchen utensils – plates, pots and pans", "Choice of restaurants", "Hotels and airlines", "Luggage", "Getting a pet", "Joining a gym", "Hairdresser and beautician", "Car repairs", "Plants for the yard", "Perfumes and cosmetics", "Running shoes", "Everyday jewelry", "Kid’s bicycles", "Internet provider", "Everyday home loans and credit cards", "House repairs, paint, tools", "Regular doctor and dentist");
    
    public static void main (String[] args) {
        String separator = args[0];
        StringBuilder sb = new StringBuilder();

        for(int i = 1; i < args.length-1; i++) {
            sb.append(getRandom(args[i])).append(separator);
        }
        sb.append(getRandom(args[args.length-1]));
        System.out.println(sb.toString());
    } 

    private static String getRandom(String kind) {
        switch(kind) {
            case "female":
                return getRandom(femaleNames);
            case "male":
                return getRandom(maleNames);
            case "name":
                return getRandom(names);
            case "country":
                return getRandom(countries);
            case "id":
                return Integer.toString(RANDOM.nextInt(MAX_LOW_ID));
            case "ID":
                return Integer.toString(RANDOM.nextInt(MAX_HIGH_ID));
            case "int":
                return Integer.toString(RANDOM.nextInt());
            case "long": 
                return Long.toString(RANDOM.nextLong());
            case "double":
                return Double.toString(RANDOM.nextDouble());
            case "username":
                return "'" + getRandom(names).replace("'","").toLowerCase() + RANDOM.nextInt(999) + "'";
            case "email":
                return "'" + getRandom("username").replace("'","") + "@email.com'" ;
            case "date":
                return "'" + java.time.Instant.ofEpochMilli(Math.abs(RANDOM.nextLong()) % System.currentTimeMillis()).toString() + "'";
            case "null":
                return "null";
        }
        return "'" + kind + "'";
    }


    private static String getRandom(List<String> data) {
        return "'" + data.get(RANDOM.nextInt(data.size())) + "'";
    }

} 