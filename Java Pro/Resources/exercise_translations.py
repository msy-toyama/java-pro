"""Complete per-exercise translations for description, hint, solutionExplanation."""

# Keys: d=description, h=hint, x=solutionExplanation
EX_TRANS = {
    # ===== ch02: Output & Variables =====
    "prac_ch02_01": {
        "d": "Create a program that stores your name and age in variables and outputs them in the following format.",
        "h": "Declare a String variable and an int variable, then output with System.out.println.",
        "x": "■ String type: A reference type for handling strings in Java. Initialize with double quotes.\n■ int type: A primitive type (32-bit) for storing integers. You can assign a value at declaration.\n■ System.out.println(): A method that outputs a line to standard output, automatically adding a newline.\n■ String concatenation (+): When connecting strings with other types using +, they are automatically converted to String."
    },
    "prac_ch02_02": {
        "d": "Assign 15 to int variable a and 4 to b, then output the results of arithmetic operations (addition, subtraction, multiplication, division, remainder).",
        "h": "Integer division truncates the decimal part. % is the remainder operator.",
        "x": "■ int type: A primitive type used for arithmetic operations (+, -, *, /).\n■ double type: A 64-bit floating-point type for storing decimal numbers.\n■ System.out.println(): Outputs calculation results. You can pass expressions directly as arguments.\n■ Integer division: int / int produces a truncated result. Cast to double if you need decimals."
    },
    "prac_ch02_03": {
        "d": "Assign 1980.5 to a double variable price, then output both the value cast to int and the original value.",
        "h": "For double → int casting, place (int) before the variable. The decimal part is truncated.",
        "x": "■ Cast operator (type): Performs explicit type conversion. Example: (int) 3.14 → 3\n■ Implicit type conversion: Conversion from a smaller to a larger type (e.g., int → double) is done automatically.\n■ String.valueOf(): A static method that converts primitive types to String.\n■ Integer.parseInt(): A static method that converts a string to int. Throws an exception for non-numeric strings."
    },

    # ===== ch03: Conditionals =====
    "prac_ch03_01": {
        "d": "Assign 75 to an int variable score and output \"Excellent\" for 90+, \"Good\" for 70+, \"Fair\" for 50+, and \"Fail\" otherwise.",
        "h": "Use if-else if-else to evaluate conditions from top to bottom.",
        "x": "■ if-else if-else: Evaluates multiple conditions from top to bottom, executing the first branch that is true.\n■ Comparison operators (>=, <): Compares numeric values and returns a boolean result.\n■ System.out.println(): Outputs the judgment result string.\n■ Condition evaluation order: Since conditions are evaluated from top to bottom, setting ranges correctly is important."
    },
    "prac_ch03_02": {
        "d": "Assign 3 to an int variable day and use a switch statement to output the day of the week (1=Monday, 2=Tuesday, ..., 7=Sunday).",
        "h": "Don't forget the break in each case of the switch statement.",
        "x": "■ switch statement: A control structure that branches based on a single expression's value.\n■ case label: Specifies the block to execute when the switch expression's value matches.\n■ break statement: Exits the switch statement after executing the matching case. Omitting it causes fall-through.\n■ default: The block executed when no case matches."
    },
    "prac_ch03_03": {
        "d": "Assign 7 to an int variable num and use the ternary operator to determine and output whether it is even or odd.",
        "h": "Ternary operator: condition ? trueValue : falseValue. Check for even with num % 2 == 0.",
        "x": "■ Ternary operator (condition ? true : false): A conditional expression that writes if-else in one line.\n■ Modulo operator (%): Calculates the remainder of division. Even check: num % 2 == 0.\n■ Variable assignment: The ternary operator's result can be stored in a String variable for use."
    },

    # ===== ch04: Loops =====
    "prac_ch04_01": {
        "d": "Use a for loop to calculate and output the sum of integers from 1 to 10.",
        "h": "Initialize variable sum to 0 and add values inside the loop.",
        "x": "■ for loop: Describes repeated processing in the format for(init; condition; update).\n■ Cumulative addition: Adds each iteration's value to sum using += to find the total.\n■ Loop variable: Initialized with int i = 1, with termination condition i <= 10."
    },
    "prac_ch04_03": {
        "d": "Use a while loop to count down from 5 to 1, then output \"Liftoff!\".",
        "h": "Initialize the counter variable to 5 and decrement (--) inside the loop.",
        "x": "■ while loop: Repeatedly executes the block while the condition is true.\n■ Decrement (--): An operator that decreases the variable's value by 1. Written as count--.\n■ Loop termination: Repeats while count > 0 using while(count > 0)."
    },
    "prac_ch04_02": {
        "d": "Use nested for loops to output a multiplication table (2's through 9's). Display each row on one line with values separated by spaces.",
        "h": "The outer for loop iterates over rows (2-9), the inner loop over multipliers (1-9). Use System.out.print for output without newline, then System.out.println() after the inner loop.",
        "x": "■ Nested for loops: The outer loop controls rows, the inner loop controls columns.\n■ System.out.print(): Outputs without a newline, placing multiplication values side by side.\n■ System.out.println(): After the inner loop ends, outputs a newline to move to the next row.\n■ String concatenation: Formats output by appending spaces."
    },

    # ===== ch05: Methods =====
    "prac_ch05_01": {
        "d": "Create a static method max that takes two int values and returns the larger one. Call it from the main method and output the result.",
        "h": "Set the return type to int and compare with an if statement, or use Math.max.",
        "x": "■ static method: A static method callable via ClassName.methodName().\n■ Return value (return): Returns the method's result to the caller.\n■ Parameters: Data passed to a method. Declare with type and name.\n■ Ternary operator: a > b ? a : b returns the larger of two values."
    },
    "prac_ch05_02": {
        "d": "Create a static method repeatPrint that takes a string text and a count, and outputs text count times.",
        "h": "The return type for methods that return nothing is void.",
        "x": "■ void method: A method with no return value. Executes processing only.\n■ Combined with for loop: Uses a for loop inside the method to output the string the specified number of times.\n■ Parameter usage: Receives the string to output and the count as parameters."
    },
    "prac_ch05_03": {
        "d": "Create two methods named add: one for int (2 args) and one for double (2 args). Verify that the appropriate method is called based on argument types.",
        "h": "Overloading means defining multiple methods with the same name but different parameter types or counts.",
        "x": "■ Method overloading: Defining multiple methods with the same name but different parameter types or counts.\n■ Compiler selection: The method matching the arguments at the call site is automatically chosen.\n■ Different argument counts: Can define add(int, int) and add(int, int, int)."
    },

    # ===== ch06: Arrays & Lists =====
    "prac_ch06_01": {
        "d": "Calculate and output the sum and average of the int array {80, 65, 90, 72, 88}.",
        "h": "Traverse the array with an enhanced for loop (for-each) and divide the sum by the length as double to get the average.",
        "x": "■ Array declaration: int[] numbers = {values, ...}; creates an array with initial values.\n■ Enhanced for loop: for(int n : numbers) processes all array elements sequentially.\n■ .length property: Returns the number of elements in the array.\n■ Average calculation: (double) sum / numbers.length casts to preserve decimal precision."
    },
    "prac_ch06_02": {
        "d": "Add \"Tanaka\", \"Suzuki\", \"Sato\" to an ArrayList, display the list, remove \"Suzuki\", then display the list again.",
        "h": "Import java.util.ArrayList and use add(), remove(), and an enhanced for loop.",
        "x": "■ ArrayList<E>: A class providing a variable-length list. Requires import java.util.ArrayList.\n■ add(E e): Adds an element to the end of the list.\n■ remove(int index): Removes the element at the specified index.\n■ size(): Returns the current number of elements in the list.\n■ Enhanced for loop: for(String name : list) processes all list elements sequentially."
    },
    "prac_ch06_03": {
        "d": "Sort the int array {34, 12, 56, 8, 45} using Arrays.sort, output the sorted array, then search for the position of 45 using Arrays.binarySearch.",
        "h": "Import java.util.Arrays. Use Arrays.toString to convert arrays to strings. binarySearch works on sorted arrays.",
        "x": "■ Arrays.sort(): A static method that sorts an array in ascending order. Requires import java.util.Arrays.\n■ Arrays.binarySearch(): Binary search on a sorted array. Returns the index if found.\n■ Arrays.toString(): Returns the array contents in string format."
    },

    # ===== ch07: Classes =====
    "prac_ch07_01": {
        "d": "Create a **Student** class with the following specifications.\n\n| File | Student.java |\n|---|---|\n\n| Element | Name | Type | Description |\n|------|------|------|------|\n| Field | name | String | Student's name |\n| Field | score | int | Score |\n| Constructor | Student(String, int) | - | Initializes name and score |\n| Method | showInfo() | void | Outputs \"Name: XX, Score: XX\" |\n\nCreate a Student object in the main method and call showInfo().",
        "h": "Define fields, a constructor, and methods in the class. In Java, only one public class per file is allowed.",
        "x": "■ class declaration: Defines a class with class Student {}. It acts as a blueprint.\n■ Fields (instance variables): Variables declared inside a class. Each object holds individual values.\n■ Constructor: An initialization method called with new Student(...). Defined with the same name as the class.\n■ this keyword: Used to reference the instance's own fields and methods.\n■ Method definition: Defines the object's behavior. Can use field values."
    },
    "prac_ch07_02": {
        "d": "Create a **BankAccount** class with the following specifications. Encapsulate the balance (private) so it can only be accessed through methods.\n\n| File | BankAccount.java |\n|---|---|\n\n| Element | Name | Access | Type / Return | Description |\n|------|------|----------|-------------|------|\n| Field | balance | private | int | Balance |\n| Constructor | BankAccount(int) | - | - | Sets initial balance |\n| Method | deposit(int) | public | void | Deposit |\n| Method | withdraw(int) | public | void | Withdraw (shows message if insufficient) |\n| Method | getBalance() | public | int | Returns current balance |",
        "h": "Making fields private and operating values only through methods is encapsulation. Include an insufficient balance check for withdrawals.",
        "x": "■ private modifier: Access control that prevents direct access to fields from outside.\n■ getter (getXxx()): A public method for retrieving private field values.\n■ setter (setXxx()): A public method for setting private field values.\n■ Encapsulation: A design principle that bundles data and its methods together, preventing unauthorized external access.\n■ Validation: You can verify value validity within setters to prevent invalid values."
    },

    # ===== ch08: Inheritance =====
    "prac_ch08_01": {
        "d": "Create the following class hierarchy and demonstrate polymorphism.\n\n|---|---|\n\n| Class | Type | Method | Behavior |\n|--------|------|----------|------|\n| Animal | Parent class | speak() | Outputs \"...\" |\n| Dog | Animal subclass | speak() | Outputs \"Woof!\" |\n| Cat | Animal subclass | speak() | Outputs \"Meow!\" |\n\nIn the main method, store Dog and Cat in an Animal array and call speak() in a loop.\n\n※ Following the one-class-per-file principle, create the following files: **Animal.java**, **Dog.java**, **Cat.java**, **AnimalDemo.java**",
        "h": "Overwriting a parent class method in a child class is called \"overriding\". Add the @Override annotation.",
        "x": "■ extends keyword: Creates a child class by inheriting from a parent class.\n■ super(): Calls the parent class constructor. Used at the beginning of the child class constructor.\n■ @Override annotation: Explicitly indicates that the parent class method is being overridden.\n■ Method overriding: Redefining a method with the same signature in the child class."
    },
    "prac_ch08_02": {
        "d": "Create the following interface and classes.\n\n|---|---|\n\n| Element | Type | Method | Behavior |\n|------|------|----------|------|\n| Printable | Interface | printData() | Outputs print data |\n| Report | Printable impl | printData() | Outputs \"Printing report...\" |\n| Invoice | Printable impl | printData() | Outputs \"Printing invoice...\" |\n\nIn the main method, store in a Printable array and call printData() in a loop.\n\n※ Following the one-class-per-file principle, create: **Printable.java**, **Report.java**, **Invoice.java**, **PrintableDemo.java**",
        "h": "Interfaces are declared with the interface keyword, and implementation classes use implements.",
        "x": "■ interface keyword: A type that defines only method signatures (specifications).\n■ implements keyword: Declares that a class implements an interface's contract.\n■ Abstract methods: Methods defined in interfaces must be overridden in implementing classes.\n■ Polymorphism: An interface-type variable can hold an instance of an implementing class."
    },

    # ===== ch12: Polymorphism =====
    "prac_ch12_01": {
        "d": "Create the following class hierarchy and demonstrate polymorphism using a Shape array.\n\n|---|---|\n\n| Class | Type | Fields | Method |\n|--------|------|-----------|----------|\n| Shape | Parent class | - | area(): double (returns 0.0) |\n| Circle | Shape subclass | radius: double | area(): returns π×radius² |\n| Rectangle | Shape subclass | width, height: double | area(): returns width×height |\n\nIn the main method, store Circle and Rectangle in a Shape array and output each shape's area.\n\n※ Following the one-class-per-file principle, create: **Shape.java**, **Circle.java**, **Rectangle.java**, **ShapeDemo.java**",
        "h": "The ability to reference child class objects with parent class types is polymorphism.",
        "x": "■ Abstract class (abstract class): A class that cannot be directly instantiated. Defines common functionality and abstract methods.\n■ abstract method: A method without a body. Must be implemented in subclasses.\n■ Polymorphism: Parent class type variables hold subclass instances, and the appropriate method is called at runtime.\n■ Math.PI: The constant for π (3.141592653589793). Provided by java.lang.Math."
    },

    # ===== ch13: Abstract Classes & Interfaces =====
    "prac_ch13_01": {
        "d": "Create the following abstract class and concrete classes.\n\n|---|---|\n\n| Class | Type | Method | Behavior |\n|--------|------|----------|------|\n| Vehicle | Abstract class | fuelType(): String (abstract) | Returns fuel type |\n| ElectricCar | Vehicle subclass | fuelType() | Returns \"Electric\" |\n| GasolineCar | Vehicle subclass | fuelType() | Returns \"Gasoline\" |\n\nIn the main method, store in a Vehicle array and output each vehicle's fuel type.\n\n※ Following the one-class-per-file principle, create: **Vehicle.java**, **ElectricCar.java**, **GasolineCar.java**, **VehicleDemo.java**",
        "h": "Abstract classes cannot be directly instantiated. Child classes must implement the abstract methods.",
        "x": "■ abstract class: An abstract class that can have common state (fields) and methods.\n■ abstract method: A method that forces implementation in child classes.\n■ protected modifier: An access level accessible from the same package and subclasses.\n■ super.method(): Syntax for calling a parent class method from a child class."
    },

    # ===== ch09: Exception Handling =====
    "prac_ch09_01": {
        "d": "Perform the calculation 10 ÷ 0 and output \"Cannot divide by zero\" when an ArithmeticException occurs.",
        "h": "When an exception occurs in the try block, processing moves to the catch block. finally executes regardless of exceptions.",
        "x": "■ try-catch: Write code that may throw exceptions in the try block and catch them in catch.\n■ ArithmeticException: An unchecked exception thrown on division by zero.\n■ e.getMessage(): A method that retrieves the error message from the exception object.\n■ Exception propagation: Uncaught exceptions propagate up the call stack."
    },
    "prac_ch09_02": {
        "d": "Create a custom AgeException (for invalid age) and throw it when the age is less than 0 or greater than 150.\n\n※ Following the one-class-per-file principle, create: **AgeException.java**, **AgeValidator.java**",
        "h": "Create a custom class extending Exception and throw it with throw new.",
        "x": "■ Custom exception class: You can define custom exceptions by extending Exception.\n■ throws declaration: Tells the caller that the method may throw a checked exception.\n■ throw new: Syntax for creating and throwing an exception instance.\n■ super(message): Passes a message to the parent class (Exception) constructor for initialization."
    },

    # ===== ch14: Advanced Exceptions =====
    "prac_ch14_01": {
        "d": "Write code where both array access and number conversion can throw exceptions, and handle them with multi-catch (catching multiple exceptions in one catch).",
        "h": "Since Java 7, you can write catch (ExceptionA | ExceptionB e).",
        "x": "■ Multi-catch (catch(A | B e)): Handles multiple exception types in one catch block, separated by pipe (|).\n■ NumberFormatException: Thrown when parsing a non-numeric string.\n■ ArrayIndexOutOfBoundsException: Thrown when accessing an array index outside its bounds.\n■ finally block: A block that always executes regardless of whether an exception occurred."
    },

    # ===== ch25: Practical Exceptions =====
    "prac_ch25_01": {
        "d": "Implement exception chaining where a ServiceException (custom exception) retains the original cause exception.\n\n※ Following the one-class-per-file principle, create: **ServiceException.java**, **ExceptionChainDemo.java**",
        "h": "Passing a cause (the original exception) to the new exception's constructor creates an exception chain. Use getCause() to retrieve the original exception.",
        "x": "■ Exception chaining: A technique of passing the original exception as the cause when throwing a new exception.\n■ initCause() / constructor argument: Two ways to set the cause exception.\n■ getCause(): A method to retrieve the chained cause exception.\n■ Troubleshooting: Chaining allows converting to higher-layer exceptions without losing original error information."
    },

    # ===== ch15: Java API =====
    "prac_ch15_01": {
        "d": "Perform uppercase conversion, character count, substring extraction (characters 7-10), and replacement (Java→Python) on the string \"Hello, Java World!\" and output the results.",
        "h": "Use String class methods: toUpperCase(), length(), substring(), replace(). substring uses 0-based indexing.",
        "x": "■ String.length(): Returns the length (character count) of the string.\n■ String.toUpperCase(): Returns a new String with all characters converted to uppercase.\n■ String.substring(begin, end): Extracts a substring from the specified range. end is exclusive.\n■ String.contains(CharSequence): Returns a boolean indicating whether the specified string is contained.\n■ String is immutable: Method calls don't change the original string; a new String is returned."
    },
    "prac_ch15_02": {
        "d": "Use StringBuilder to concatenate numbers from 1 to 5 with commas, remove the last comma, and output the result.",
        "h": "StringBuilder uses append to add strings and deleteCharAt to remove characters at specific positions. It's faster than String + concatenation.",
        "x": "■ StringBuilder: A mutable string buffer. More efficient than String for frequent concatenation.\n■ append(): Adds a string to the end of the buffer.\n■ toString(): Converts the StringBuilder content to a String.\n■ reverse(): Reverses the string order. Modifies the StringBuilder itself (destructive operation)."
    },

    # ===== ch26: Date & Time =====
    "prac_ch26_01": {
        "d": "Get today's date, output it in \"yyyy/MM/dd\" format, then also output the date 30 days later.",
        "h": "Get today's date with LocalDate.now() and add days with plusDays(30). Specify the format with DateTimeFormatter. The output date depends on the execution date.",
        "x": "■ LocalDate: A date class from the java.time package (date only, no time). An immutable object.\n■ LocalDate.now(): A static method that gets the current date.\n■ plusDays(long): Returns a new LocalDate the specified number of days later (the original object is not modified).\n■ DateTimeFormatter.ofPattern(): Creates a formatter specifying the date format pattern.\n■ format(DateTimeFormatter): Converts a LocalDate to a string in the specified format."
    },

    # ===== ch30: Annotations =====
    "prac_ch30_01": {
        "d": "Create a class with the following specifications.\n\n| File | AnnotationDemo.java |\n|---|---|\n\n| Method | Annotation | Description |\n|----------|--------------|------|\n| oldMethod() | @Deprecated | Deprecated method |\n| newMethod() | None | Replacement method |\n\nCall both methods in the main method and verify that a @Deprecated warning appears at compile time.",
        "h": "Adding @Deprecated causes a compile-time warning wherever that method is called.",
        "x": "■ @Deprecated: A standard annotation indicating that a method or class is deprecated.\n■ @SuppressWarnings: An annotation that suppresses compiler warnings. \"deprecation\" suppresses deprecation warnings.\n■ @Override: Indicates that a method overrides a superclass method."
    },

    # ===== ch19: Java 17 Features =====
    "prac_ch19_02": {
        "d": "Use text blocks (\"\"\"...\"\"\") to store a multiline JSON string in a variable and output it.",
        "h": "Text blocks are triple-quoted strings available since Java 13 that can include newlines and indentation as-is.",
        "x": "■ Text blocks (\"\"\"...\"\"\"): Multiline string literals available since Java 13.\n■ Indentation control: The position of the closing \"\"\" automatically removes unnecessary indentation.\n■ No escaping needed: Double quotes inside text blocks usually don't need escaping."
    },
    "prac_ch19_01": {
        "d": "Use Java 14+ switch expressions (-> syntax) to determine and output the season from a month number (1-12). Use month 4.",
        "h": "Switch expressions can return values and use -> instead of break.",
        "x": "■ Switch expression (arrow syntax →): A new switch syntax available since Java 14. No break needed, no fall-through.\n■ yield keyword: Used to return a value from a block within a switch expression.\n■ Switch expression assignment: Can be directly assigned to a variable: String result = switch(x) { ... };"
    },

    # ===== ch21: Generics =====
    "prac_ch21_01": {
        "d": "Create a generics class with the following specifications.\n\n| File | BoxTest.java |\n|---|---|\n\n| Class | Type Param | Fields | Methods |\n|--------|------------|-----------|----------|\n| Box\\<T\\> | T | value: T | getValue(): T, setValue(T): void |\n\nCreate a String Box and an Integer Box, retrieve each value and output.\n\n※ Following the one-class-per-file principle, create: **Box.java**, **BoxDemo.java**",
        "h": "<T> is a type parameter. The specific type is not specified at class definition time but is determined at usage time.",
        "x": "■ Generics (<T>): A mechanism for making classes and methods generic using type parameters.\n■ Type safety: Type checking occurs at compile time, preventing ClassCastException.\n■ Type parameter T: First letter of Type. Convention uses T, E, K, V, etc.\n■ Generic class instantiation: Specify the type argument like new Box<String>(\"hello\")."
    },

    # ===== ch22: Collections =====
    "prac_ch22_02": {
        "d": "Create a program that removes duplicates from an integer array and displays the sorted result using TreeSet.",
        "h": "HashSet is a collection that doesn't allow duplicates. TreeSet automatically sorts elements.",
        "x": "■ TreeSet<E>: A Set implementation that keeps elements sorted in natural order (ascending).\n■ add(E e): Adds an element to the Set. Duplicate elements are not added.\n■ Set characteristic: A collection that doesn't allow duplicates. Adding the same value keeps only one.\n■ TreeSet vs HashSet: TreeSet is sorted; HashSet is unordered but faster."
    },
    "prac_ch22_01": {
        "d": "Create a program that counts word occurrences in a string array using LinkedHashMap.",
        "h": "Use LinkedHashMap<String, Integer> and getOrDefault to get existing values while counting up. LinkedHashMap preserves insertion order.",
        "x": "■ LinkedHashMap<K,V>: A Map implementation that preserves insertion order. Unlike HashMap, the order is predictable.\n■ put(K key, V value): Adds a key-value pair to the Map.\n■ getOrDefault(K key, V defaultValue): Returns the value if the key exists, otherwise the default value.\n■ entrySet(): Returns a Set of all entries (key-value pairs) in the Map.\n■ Map.Entry<K,V>: An interface representing a single Map entry. Use getKey() and getValue() to access values."
    },

    # ===== ch16: Lambda =====
    "prac_ch16_01": {
        "d": "Sort the string list {\"banana\", \"apple\", \"cherry\"} alphabetically using a lambda expression and output the result.",
        "h": "Pass a lambda expression like (a, b) -> a.compareTo(b) as the second argument to Collections.sort.",
        "x": "■ Lambda expression ((args) -> expression): A syntax for concisely implementing functional interfaces.\n■ Comparator<T>: A functional interface that defines comparison rules for two objects.\n■ Collections.sort(List, Comparator): Sorts a list using the specified Comparator.\n■ List.sort(Comparator): The List's own sort method. Equivalent to Collections.sort."
    },

    # ===== ch23: Functional Interfaces =====
    "prac_ch23_01": {
        "d": "Use Predicate<Integer> to filter only even numbers from the list {1,2,...,10} and output them.",
        "h": "Predicate<T> is a functional interface that returns true/false via its test(T) method.",
        "x": "■ Predicate<T>: A functional interface that takes an argument and returns boolean.\n■ test(T t): The Predicate method. Returns true if the condition is met.\n■ and() / or(): Default methods for combining multiple Predicates with logical operations.\n■ removeIf(Predicate): A method that removes elements matching the condition from a collection."
    },

    # ===== ch24: Stream API =====
    "prac_ch24_01": {
        "d": "From the integer list {1,2,3,4,5,6,7,8,9,10}, filter even numbers, square each value, then calculate the sum.",
        "h": "Use stream().filter().map().reduce() or .sum(). Use mapToInt for conversion to int.",
        "x": "■ Stream API: A pipeline mechanism for processing collection data in a functional style.\n■ stream(): Creates a Stream from a collection.\n■ filter(Predicate): An intermediate operation that passes only elements matching the condition.\n■ map(Function): An intermediate operation that transforms each element.\n■ collect(Collectors.toList()): A terminal operation that collects Stream results into a List.\n■ reduce(): A terminal operation that folds (accumulates) elements."
    },
    "prac_ch24_02": {
        "d": "From the name list {\"tanaka\", \"suzuki\", \"sato\", \"takahashi\"}, convert only names with 5+ characters to uppercase and output them comma-separated.",
        "h": "Combine filter → map → Collectors.joining.",
        "x": "■ Stream<String>: A stream of strings. Powerful when combined with string operations.\n■ map(String::toUpperCase): Transformation using method reference. Equivalent to lambda s -> s.toUpperCase().\n■ sorted(): An intermediate operation that sorts in natural order (alphabetical).\n■ forEach(Consumer): A terminal operation that performs an action on each element."
    },

    # ===== ch10: Database =====
    "prac_ch10_01": {
        "d": "Write the following SQL statement: a SELECT query to retrieve employees from the development department in the employees table, sorted by salary in descending order.\n※ This is an SQL writing exercise, not Java. Save as an SQL file.",
        "h": "Use the syntax: SELECT ... FROM ... WHERE ... ORDER BY ... DESC.",
        "x": "■ SQL (Structured Query Language): A language for manipulating relational databases.\n■ CREATE TABLE: A DDL statement for creating new tables.\n■ INSERT INTO: A DML statement for adding data rows to tables.\n■ SELECT: A DML statement for querying data from tables. Use WHERE clause for conditions."
    },

    # ===== ch29: JDBC =====
    "prac_ch29_01": {
        "d": "Create a program that fetches all records from the MySQL employees table using JDBC and outputs them.\n※ Requires the \"Database Environment Setup\" from the setup guides.",
        "h": "Connect to the DB with DriverManager.getConnection and execute SQL with PreparedStatement. Use try-with-resources to automatically close resources.",
        "x": "■ DriverManager.getConnection(): A static method that establishes a JDBC connection. Specify URL, username, and password.\n■ Connection: An interface representing the database connection.\n■ PreparedStatement: An interface for executing parameterized SQL. Effective against SQL injection.\n■ ResultSet: Represents a SELECT query result set. Use next() to advance through rows.\n■ try-with-resources: Syntax that automatically close()s AutoCloseable resources."
    },

    # ===== ch38: Spring Boot =====
    "prac_ch38_01": {
        "d": "Create an API using Spring Boot's @RestController that returns \"Hello, Taro!\" when /api/greeting?name=Taro is accessed.\n※ Requires the \"Web App Development Environment\" from the setup guides.",
        "h": "Use @GetMapping to handle HTTP GET requests and @RequestParam to get the ?name=xxx value.",
        "x": "■ @RestController: A Spring Boot annotation applied to RESTful API controller classes.\n■ @GetMapping(\"/path\"): Applied to methods handling HTTP GET requests.\n■ @RequestParam: Binds query parameters (?key=value) to method arguments.\n■ ResponseEntity<T>: A class that returns HTTP status code and response body together."
    },

    # ===== ch27: Concurrency =====
    "prac_ch27_01": {
        "d": "Create two threads using the Runnable interface, each outputting \"Thread A\" and \"Thread B\" three times.",
        "h": "Start threads with new Thread(Runnable).start(). Thread execution order is not guaranteed.",
        "x": "■ Runnable interface: A functional interface with a run() method. Defines the processing to execute in a thread.\n■ Thread class: A class representing Java threads. Create threads with new Thread(runnable).\n■ start(): Starts the thread. Calling run() directly doesn't create a new thread.\n■ Thread.sleep(millis): Pauses the thread for the specified milliseconds. Must handle InterruptedException."
    },

    # ===== ch28: I/O =====
    "prac_ch28_01": {
        "d": "Use the Files class to write 3 lines to a text file, then read and output the file.",
        "h": "Use write() and readAllLines() from java.nio.file.Files. Create a Path with Paths.get().",
        "x": "■ Files.write(): A file writing method from java.nio.file package. Takes Path and List<String>.\n■ Files.readAllLines(): Reads all lines of a file as List<String>.\n■ Path.of(): A static method that creates a file path. Returns java.nio.file.Path.\n■ StandardCharsets.UTF_8: A constant specifying character encoding."
    },

    # ===== ch17: Module System =====
    "prac_ch17_01": {
        "d": "Use module-info.java syntax to declare that the myapp module requires the java.sql module.\n※ This is a file writing exercise for learning syntax.",
        "h": "Declare the module name with the module keyword and specify dependencies with requires.",
        "x": "■ module-info.java: The module descriptor file. Defines the module's name, dependencies, and exported packages.\n■ module declaration: Defines a module with module moduleName { }.\n■ requires: A directive declaring dependency on another module.\n■ exports: A directive that exposes a package to other modules."
    },

    # ===== ch32: Module Details =====
    "prac_ch32_01": {
        "d": "Write a module-info.java where module mylib exports the com.mylib.api package and keeps the com.mylib.internal package private.",
        "h": "Specify packages to export with exports. Packages not specified cannot be accessed externally.",
        "x": "■ exports packageName: Makes the specified package publicly available outside the module.\n■ exports ... to: Qualified export that limits exposure to specific modules.\n■ requires transitive: Transitive dependency. The dependency propagates to modules that use this module."
    },

    # ===== ch31: Localization =====
    "prac_ch31_01": {
        "d": "Use Locale to format the same number 1234567.89 in Japanese, American, and German formats and output them.",
        "h": "Pass Locale.JAPAN, Locale.US, Locale.GERMANY to NumberFormat.getNumberInstance.",
        "x": "■ Locale: A class representing language, country, and region. Has constants like Locale.JAPAN, Locale.US.\n■ NumberFormat.getCurrencyInstance(Locale): Gets a currency formatter appropriate for the locale.\n■ format(double): Converts a number to the specified locale's currency format.\n■ Internationalization (i18n): A design approach for making applications support multiple languages and regions."
    },

    # ===== ch20: Nested Classes =====
    "prac_ch20_01": {
        "d": "Create the following class structure.\n\n| File | OuterTest.java |\n|---|---|\n\n| Class | Type | Members |\n|--------|------|--------|\n| Outer | Outer class | message: String |\n| Outer.Config | Static inner class | version: String, debug: boolean |\n\nAccess **Outer.Config** from outside and output the settings.",
        "h": "Static nested classes can be created without an instance of the outer class. Access with Outer.Inner format.",
        "x": "■ Static nested class: A class defined with static inside an outer class. Can be used without an outer class instance.\n■ OuterClass.InnerClass: How to reference a static nested class.\n■ Access modifiers: Nested classes can also have public/private and other modifiers applied."
    },

    # ===== Comprehensive Basics =====
    "comp_basics_01": {
        "d": "Create a grade management program for 5 students, calculating the following from an array or ArrayList of scores:\n- Sum and average\n- Highest and lowest scores\n- Number of students who passed (60+)\n\n[Required Knowledge] Arrays, for loops, if statements, methods",
        "h": "Create methods for each type of calculation (sum, max, min, pass count) and call them from main.",
        "x": "■ Array traversal: Processes all elements sequentially using an enhanced for loop.\n■ Conditional counting: Uses if statements inside a loop to count elements meeting conditions.\n■ Method decomposition: Separating processing into methods like sum(), average(), max() improves readability.\n■ Type casting: Uses (double) sum / count to calculate the decimal average."
    },
    "comp_basics_02": {
        "d": "Create a rock-paper-scissors game where the player's choice is fixed (e.g., rock) and the computer's choice is randomly determined. Display both choices and the result (win/lose/draw).\n\n[Required Knowledge] if-else, random numbers (Math.random or switch), methods",
        "h": "Convert Math.random() to 0-2 and map to rock/paper/scissors. Determine the result by comparing player and computer choices.",
        "x": "■ Math.random(): Returns a random double from 0.0 to 1.0. Multiply and cast to int for integer range.\n■ switch: Maps numeric values (0, 1, 2) to strings (Rock, Paper, Scissors).\n■ Conditional branching: Comprehensive win/lose/draw logic using if-else if-else.\n■ Method separation: Separating display logic and judgment logic clarifies the code structure."
    },
    "comp_basics_03": {
        "d": "Create a program that takes a string and performs the following using methods:\n- Reverse the string\n- Count vowels\n- Convert to uppercase\n\n[Required Knowledge] String, charAt, for loop, methods",
        "h": "Use charAt() in a loop for reversal, and check characters against 'a','e','i','o','u' for vowel counting.",
        "x": "■ String.charAt(i): Gets the character at position i as a char.\n■ StringBuilder: Used for efficiently building reversed strings by appending characters.\n■ Character.toLowerCase(): Converts to lowercase for case-insensitive comparison.\n■ Method decomposition: Creating separate methods for reverse(), countVowels(), toUpper() clarifies responsibilities."
    },
    "comp_basics_04": {
        "d": "Create a simple budget tracker that manages income and expenses using arrays and methods, then displays total income, total expenses, and balance. Determine whether it's in the black or red.\n\n[Required Knowledge] Arrays, for loops, methods, if statements",
        "h": "Store income and expenses in separate arrays, calculate totals with loops, and determine black/red from the difference.",
        "x": "■ Array management: Uses separate arrays for income and expenses (or ArrayList).\n■ Sum method: Calculates the sum by iterating through an array with for-each.\n■ Balance calculation: Balance = total income - total expenses.\n■ String formatting: Uses System.out.printf or string concatenation for formatted output."
    },
    "comp_basics_05": {
        "d": "Create a program that takes an integer and determines whether it is prime. Check multiple numbers and display the results.\n\n[Required Knowledge] for loops, if statements, break, methods, modulo operator",
        "h": "For prime checking, test divisibility from 2 to the square root. Use Math.sqrt() for the upper bound.",
        "x": "■ Prime determination algorithm: Tests divisibility from 2 to √n. If any divisor is found, it's not prime.\n■ Math.sqrt(): Returns the square root of a number. Limits the loop range.\n■ break: Immediately exits the loop when a divisor is found.\n■ boolean return: The isPrime() method returns true/false for clear caller-side processing."
    },
    "comp_basics_06": {
        "d": "Implement a simple calculator that evaluates **Reverse Polish Notation (RPN)** expressions. Supports +, -, *, / operators for integers.\n\n[Required Knowledge] Stack (ArrayDeque), switch, String.split, Integer.parseInt\n\nExample: \"3 4 + 2 *\" → (3 + 4) * 2 = 14",
        "h": "Process tokens from left to right: push numbers to the stack, pop two values for operators, compute, and push the result.",
        "x": "■ Stack (ArrayDeque): Implements LIFO (Last In, First Out) data structure. Uses push/pop/peek.\n■ Reverse Polish Notation: No operator precedence or parentheses needed. Simple stack-based evaluation.\n■ String.split(\" \"): Splits the expression string into tokens by spaces.\n■ switch for operators: Performs the appropriate arithmetic operation for each operator."
    },
    "comp_basics_07": {
        "d": "Represent a small maze (2D array) and find the path from start (S) to goal (G). Output the found path as coordinates.\n\n[Required Knowledge] 2D arrays, recursion or loops, boolean visited tracking",
        "h": "Use a boolean[][] visited array to track visited cells. Try 4 directions (up, down, left, right) recursively or with a queue.",
        "x": "■ 2D char array: Represents the maze with '#' for walls, ' ' for paths, 'S' for start, 'G' for goal.\n■ Recursive search (DFS): Tries each direction and backtracks if blocked.\n■ Boundary check: Verifies row/column are within valid range before accessing the array.\n■ visited array: boolean[][] prevents revisiting the same cell (infinite loop prevention)."
    },

    # ===== Comprehensive OOP =====
    "comp_oop_01": {
        "d": "Create a library book management system.\n\n| File | Description |\n|---|---|\n| Book.java | Book class (ISBN, title, author) |\n| Library.java | Library class (manages book list) |\n| LibraryDemo.java | Main method |\n\nImplement add, list, and search by ISBN functionality.\n\n※ Following the one-class-per-file principle, create: **Book.java**, **Library.java**, **LibraryDemo.java**",
        "h": "Use ArrayList<Book> for the collection. Implement search with a loop checking ISBN equality.",
        "x": "■ Encapsulation: Book's fields are private, accessed through getters.\n■ ArrayList<Book>: A dynamic list holding Book objects.\n■ toString() override: Customizes the string representation of Book objects for display.\n■ Sequential search: Iterates through the list to find a matching ISBN."
    },
    "comp_oop_02": {
        "d": "Create an employee payroll calculation system.\n\n| Class | Type | Description |\n|------|------|------|\n| Employee | Abstract class | name, baseSalary, abstract calculatePay() |\n| FullTimeEmployee | Subclass | Fixed salary |\n| PartTimeEmployee | Subclass | hourlyRate × hoursWorked |\n\nDisplay each employee's name and calculated pay.\n\n※ Following the one-class-per-file principle, create: **Employee.java**, **FullTimeEmployee.java**, **PartTimeEmployee.java**, **PayrollDemo.java**",
        "h": "Define calculatePay() as abstract in Employee. Each subclass implements it with its own calculation logic.",
        "x": "■ Abstract class: Employee defines the common interface while leaving implementation to subclasses.\n■ Template pattern: The parent class defines the processing framework, with specifics delegated to subclasses.\n■ Polymorphism: Employee array holds different subclass types, each calling its own calculatePay().\n■ @Override: Explicitly indicates that the parent's abstract method is being implemented."
    },
    "comp_oop_03": {
        "d": "Create a payment processing system using interfaces.\n\n| Element | Type | Description |\n|------|------|------|\n| Payment | Interface | pay(int amount) |\n| CreditCardPayment | Implementation | Credit card payment |\n| BankTransferPayment | Implementation | Bank transfer |\n| CashPayment | Implementation | Cash payment |\n\n※ Following the one-class-per-file principle, create: **Payment.java**, **CreditCardPayment.java**, **BankTransferPayment.java**, **CashPayment.java**, **PaymentDemo.java**",
        "h": "Define the pay() method in the Payment interface, and implement different payment behaviors in each class.",
        "x": "■ Interface: Payment defines the contract (pay method) for all payment types.\n■ Polymorphism: Payment type variable can hold any implementation class instance.\n■ Loose coupling: Adding new payment methods only requires implementing the interface.\n■ Strategy pattern: Different payment strategies can be interchanged at runtime."
    },
    "comp_oop_04": {
        "d": "Create a zoo simulator.\n\n| Class | Type | Method | Behavior |\n|------|------|---------|------|\n| Animal | Abstract class | speak(), move() | Abstract |\n| Swimmable | Interface | swim() | Can swim |\n| Dog | Subclass + Swimmable | speak(), move(), swim() | Woof / walk / swim |\n| Cat | Subclass | speak(), move() | Meow / walk |\n| Bird | Subclass | speak(), move() | Tweet / fly |\n\n※ Following the one-class-per-file principle, create: **Animal.java**, **Swimmable.java**, **Dog.java**, **Cat.java**, **Bird.java**, **ZooDemo.java**",
        "h": "Use abstract class for common animal features and an interface for the swimming ability. Dog implements both.",
        "x": "■ Abstract class + Interface: Combines inheritance (is-a) with capability declaration (can-do).\n■ implements multiple interfaces: A class can implement multiple interfaces.\n■ Polymorphism: Animal array stores different animal types, each calling their own methods.\n■ instanceof: Checks if an object implements the Swimmable interface for conditional behavior."
    },
    "comp_oop_05": {
        "d": "Create an e-commerce product management system.\n\n| Class | Description |\n|------|------|\n| Product | Abstract class (name, price) |\n| PhysicalProduct | Subclass (adds shippingWeight) |\n| DigitalProduct | Subclass (adds downloadUrl) |\n| SubscriptionProduct | Subclass (adds monthlyFee) |\n| ShoppingCart | Manages products, calculates total |\n\n※ Following the one-class-per-file principle, create: **Product.java**, **PhysicalProduct.java**, **DigitalProduct.java**, **SubscriptionProduct.java**, **ShoppingCart.java**, **ShopDemo.java**",
        "h": "Define abstract getDisplayPrice() in Product. Each subclass formats its price display differently.",
        "x": "■ Class hierarchy: Product as the base, with Physical/Digital/Subscription as specialized types.\n■ Abstract method: Each product type implements getDisplayPrice() with its own format.\n■ ArrayList<Product>: ShoppingCart holds different product types in a single list.\n■ Polymorphism: Total calculation loops through Product list, calling each type's method."
    },
    "comp_oop_06": {
        "d": "Implement the **Observer pattern**: create a stock price monitor that notifies observers when the price changes.\n\n| Class | Description |\n|------|------|\n| StockSubject | Subject that holds stock price, notifies observers |\n| PriceDisplay | Observer that displays current price |\n| AlertObserver | Observer that alerts when price exceeds threshold |\n\n※ Following the one-class-per-file principle, create: **Observer.java**, **StockSubject.java**, **PriceDisplay.java**, **AlertObserver.java**, **ObserverDemo.java**",
        "h": "Define an Observer interface with update() method. StockSubject holds a list of observers and calls update() on price changes.",
        "x": "■ Observer pattern: Establishes a one-to-many dependency, automatically notifying dependents of state changes.\n■ Loose coupling: Subject only depends on the Observer interface, not concrete observers.\n■ ArrayList<Observer>: Manages registered observers in a list, iterating to notify each.\n■ Interface-based design: New observer types can be added without modifying the Subject."
    },
    "comp_oop_07": {
        "d": "Implement the **Strategy pattern**: create a discount calculator where different discount strategies can be applied.\n\n| Element | Type | Description |\n|------|------|------|\n| DiscountStrategy | Interface | calculate(int price): int |\n| NoDiscount | Implementation | Returns original price |\n| PercentageDiscount | Implementation | Percentage discount |\n| FixedDiscount | Implementation | Fixed amount discount |\n| PriceCalculator | Context | Applies strategy |\n\n※ Following the one-class-per-file principle, create: **DiscountStrategy.java**, **NoDiscount.java**, **PercentageDiscount.java**, **FixedDiscount.java**, **PriceCalculator.java**, **StrategyDemo.java**",
        "h": "Define DiscountStrategy as a functional interface. PriceCalculator holds a strategy and delegates calculation to it.",
        "x": "■ Strategy pattern: Encapsulates algorithms as interchangeable objects, enabling runtime algorithm selection.\n■ @FunctionalInterface: DiscountStrategy can also be expressed as a lambda.\n■ Composition over inheritance: PriceCalculator holds a strategy (has-a) rather than inheriting.\n■ Open/Closed principle: New strategies can be added without modifying existing code."
    },

    # ===== Comprehensive Error Handling =====
    "comp_error_01": {
        "d": "Create a program that validates string input by attempting to convert it to an integer and verifying the value is within the range 1-100.\n\n[Required Knowledge] try-catch, NumberFormatException, range validation with if",
        "h": "Wrap Integer.parseInt() in try-catch, then perform range checking on success.",
        "x": "■ Integer.parseInt(): Converts a string to int. Throws NumberFormatException if conversion fails.\n■ try-catch: Wraps code that may throw exceptions in try, handles them in catch.\n■ Range check: After successful parsing, validates value with if statements."
    },
    "comp_error_02": {
        "d": "Create a method that simulates file reading and throws different exceptions based on the filename. Use multi-catch and finally.\n\n[Required Knowledge] Custom exceptions, multi-catch, finally, throws\n\n※ Following the one-class-per-file principle, create: **DataCorruptException.java**, **FileReadSimulator.java**",
        "h": "Define FileNotFoundException and a custom DataCorruptException, using them differently based on the filename.",
        "x": "■ throws: Declares to the caller that the method may throw checked exceptions.\n■ Multi-catch (A | B e): Handles multiple exception types in one catch block.\n■ finally: A block that always executes regardless of exceptions. Used for resource cleanup.\n■ Checked vs unchecked: FileNotFoundException is a checked exception requiring catch or throws."
    },
    "comp_error_03": {
        "d": "Create the following classes and custom exceptions.\n\n|---|---|\n\n| Element | Type | Description |\n|------|------|------|\n| InsufficientFundsException | Custom exception | Thrown when balance is insufficient |\n| InvalidAmountException | Custom exception | Thrown for invalid amounts (≤0) |\n| BankAccount | Class | Throws exceptions in deposit/withdraw methods |\n\n| Method | Exception Condition |\n|----------|----------|\n| deposit(int) | Amount ≤ 0 → InvalidAmountException |\n| withdraw(int) | Amount ≤ 0 → InvalidAmountException |\n| withdraw(int) | Insufficient balance → InsufficientFundsException |\n\n※ Following the one-class-per-file principle, create: **InsufficientFundsException.java**, **InvalidAmountException.java**, **Account.java**, **BankAccount.java**",
        "h": "Define InsufficientFundsException and InvalidAmountException. Check conditions in deposit() and withdraw() and throw exceptions if invalid.",
        "x": "■ Custom exceptions: Define business-specific exceptions by extending Exception.\n■ throw new: Throws an exception and interrupts processing when the condition is met.\n■ Encapsulation: balance is private, operable only through deposit/withdraw methods.\n■ Multiple try-catch: Separates exception handling for different error scenarios."
    },
    "comp_error_04": {
        "d": "Create a program that parses configuration strings in \"key=value\" format. Define three types of exceptions hierarchically (format error, unknown key, type mismatch) and use exception chaining.\n\n[Required Knowledge] Exception hierarchy, exception chaining, initCause/getCause\n\n※ Following the one-class-per-file principle, create: **ConfigException.java**, **FormatException.java**, **TypeException.java**, **ConfigParser.java**",
        "h": "Define FormatException and TypeException under ConfigException as the base. Incorporate exceptions at each parsing stage into the chain.",
        "x": "■ Exception hierarchy: ConfigException is the parent; Format/TypeException represent specific causes.\n■ Exception chaining: Retains the cause exception with new ConfigException(msg, cause).\n■ getCause(): Retrieves the chained cause exception for debugging information.\n■ Rethrowing: Catches low-level exceptions and converts them to higher-level exceptions before throwing."
    },
    "comp_error_05": {
        "d": "Create the following AutoCloseable implementation classes and use them with try-with-resources.\n\n|---|---|\n\n| Class | Implements | Methods | Description |\n|--------|------|----------|------|\n| DatabaseConnection | AutoCloseable | open(), query(String), close() | DB connection simulation |\n| FileHandler | AutoCloseable | write(String), close() | File writing simulation |\n\nUse both resources with try-with-resources and verify that resources are reliably closed even when errors occur.\n\n※ Following the one-class-per-file principle, create: **DatabaseConnection.java**, **FileHandler.java**, **ResourceManager.java**",
        "h": "Implement AutoCloseable's close() method. In try-with-resources, close() is called in reverse declaration order.",
        "x": "■ AutoCloseable: An interface with close(). close() is automatically called in try-with-resources.\n■ try-with-resources: Automatically calls close() when the block ends using try(resource declaration).\n■ Close order: Resources are closed in reverse declaration order (FileHandler → DatabaseConnection).\n■ Exception safety: Resources are reliably closed even when exceptions occur."
    },
    "comp_error_06": {
        "d": "Simulate an unstable network connection and implement an HTTP client with a **retry mechanism**.\n\n| File | Role |\n|-------------|------|\n| NetworkException.java | Network exception |\n| RetryableException.java | Retryable exception |\n| HttpClient.java | HTTP request (fails randomly) |\n| RetryExecutor.java | Retry logic |\n| RetryDemo.java | Main method |\n\n- Make maximum retry count configurable\n- Make retry interval (milliseconds) configurable\n- Distinguish between retryable and non-retryable exceptions\n\n※ Following the one-class-per-file principle, create: **NetworkException.java**, **RetryableException.java**, **HttpClient.java**, **RetryExecutor.java**, **RetryDemo.java**",
        "h": "RetryExecutor should take a Functional Interface as an argument and implement a generic method that catches exceptions and retries.",
        "x": "■ Exception hierarchy design\nNetworkException → RetryableException inheritance distinguishes retryable from non-retryable exceptions by type.\n\n■ Generic method\nexecute<T>() implements a retry mechanism that works for any return type.\n\n■ @FunctionalInterface\nRetryableAction<T> can be passed as a lambda expression."
    },
    "comp_error_07": {
        "d": "Design and implement a **generic validation framework** for user input.\n\n| File | Role |\n|-------------|------|\n| ValidationException.java | Validation error exception (holds multiple errors) |\n| Validator.java | Functional interface for validation rules |\n| Validators.java | Utility providing common rules |\n| ValidationChain.java | Chains rules for batch validation |\n| ValidationDemo.java | Main method |\n\n- Must be able to apply multiple rules to a single value\n- Report all errors together (don't stop at the first error)\n\n※ Following the one-class-per-file principle, create: **ValidationException.java**, **Validator.java**, **Validators.java**, **ValidationChain.java**, **ValidationDemo.java**",
        "h": "ValidationChain holds List<Validator<T>>, validate() applies all rules. Collect errors in List<String> and throw them together at the end.",
        "x": "■ Method chaining\naddRule() returns this, enabling .addRule().addRule() chaining (Builder pattern).\n\n■ All error collection\nInstead of stopping at the first error, applies all rules then reports together.\n\n■ @FunctionalInterface\nValidator<T> can be written as a lambda. Easy to add custom rules."
    },

    # ===== Comprehensive Standard Library =====
    "comp_stdlib_01": {
        "d": "Create a program that analyzes a string: character count, word count, uppercase/lowercase count, and occurrences of a specific character.\n\n[Required Knowledge] String API (length, split, charAt, toUpperCase), for loop",
        "h": "Split into words with split(\" \") and check each character with charAt. Character.isUpperCase/isLowerCase is useful.",
        "x": "■ String.length(): Returns the string length (including spaces).\n■ String.split(\" \"): Splits the string by spaces and returns a word array.\n■ String.charAt(i): Gets the character at position i as char.\n■ Character.isUpperCase/isLowerCase(): Static methods that determine if a character is upper/lowercase."
    },
    "comp_stdlib_02": {
        "d": "Create a utility program that calculates days between two dates, gets the day of week, and calculates the last day of a month.\n\n[Required Knowledge] LocalDate, Period, DayOfWeek, DateTimeFormatter",
        "h": "Use Period.between() for the period and getDayOfWeek() for the day of week. Get the last day of month with withDayOfMonth(1).plusMonths(1).minusDays(1).",
        "x": "■ LocalDate.of(): A static method that creates a LocalDate for a specified date.\n■ Period.between(): Calculates the period (years/months/days) between two dates.\n■ getDayOfWeek(): Gets the day of week (DayOfWeek enum) of a date.\n■ lengthOfMonth(): Returns the number of days in the month. Useful for last-day calculations.\n■ Switch expression: Uses arrow syntax for DayOfWeek conversion."
    },
    "comp_stdlib_03": {
        "d": "Create a program that evaluates password strength (weak/medium/strong) based on 5 criteria: length, contains uppercase, contains lowercase, contains digits, and contains symbols.\n\n[Required Knowledge] String API, StringBuilder, char checking, basic regex",
        "h": "Check each criterion and add points. Determine weak(1-2)/medium(3-4)/strong(5) based on the score.",
        "x": "■ String.charAt(): Used to check each character individually.\n■ Character.isUpperCase/isLowerCase/isDigit(): Static methods for determining character types.\n■ boolean flags: Used to track whether each criterion is met.\n■ Scoring logic: A practical pattern for classifying levels based on the number of criteria met."
    },
    "comp_stdlib_04": {
        "d": "Create a schedule management program using LocalDateTime for registering, displaying, and comparing events (past/future determination).\n\n[Required Knowledge] LocalDateTime, DateTimeFormatter, isBefore/isAfter, ArrayList\n\n※ Following the one-class-per-file principle, create: **ScheduleItem.java**, **ScheduleManager.java**",
        "h": "Create event dates with LocalDateTime.of() and compare with LocalDateTime.now() using isBefore() to determine past/future.",
        "x": "■ LocalDateTime: A class that handles both date and time. Extends LocalDate with time.\n■ LocalDateTime.of(): Creates an instance with specified year/month/day/hour/minute.\n■ isBefore(): Determines if a date is before the specified datetime.\n■ DateTimeFormatter.ofPattern(): Specifies the display format for datetime.\n■ format(): Converts LocalDateTime to a formatted string."
    },
    "comp_stdlib_05": {
        "d": "Create a program that applies multiple transformations (trim, uppercase, character replace, reverse) to a string in a method-chain fashion. Output intermediate results for each transformation.\n\n[Required Knowledge] StringBuilder, String API, method design",
        "h": "Apply String's trim(), toUpperCase(), replace() and StringBuilder.reverse() sequentially.",
        "x": "■ String.trim(): Removes leading and trailing whitespace.\n■ String.toUpperCase(): Returns a new String with all characters uppercase.\n■ String.replace(old, new): Returns a new String with old replaced by new.\n■ StringBuilder.reverse(): Reverses the string.\n■ Immutability: Each String method returns a new String without modifying the original."
    },
    "comp_stdlib_06": {
        "d": "Create a program that extracts information from log files using **regular expressions**.\n\nParse the following log format:\n```\n[2024-01-15 10:30:45] ERROR UserService: Login failed (user=tanaka)\n```\n\n| Info to Extract | Example |\n|-------------|----|  \n| DateTime | 2024-01-15 10:30:45 |\n| Level | ERROR |\n| Service | UserService |\n| Message | Login failed |\n| Parameter | user=tanaka |\n\n- Count by level and output a summary\n- Output details only for ERROR level logs",
        "h": "Use Pattern.compile() and Matcher with group captures. Named groups (?<name>...) are useful.",
        "x": "■ Named capture groups\n(?<name>...) allows readable access via m.group(\"name\").\n\n■ record (Java 16+)\nDeclares LogEntry as a record for concise immutable data class definition.\n\n■ Map.merge()\ncounts.merge(level, 1L, Long::sum) writes aggregation in one line."
    },
    "comp_stdlib_07": {
        "d": "Create a program combining **sealed class** and **Builder pattern** to construct type-safe configuration values.\n\n| File | Role |\n|-------------|------|\n| ConfigValue.java | sealed interface + record (String/Int/Bool/ListVal) |\n| AppConfig.java | Builds config using Builder pattern |\n| ConfigDemo.java | Main method |\n\n- ConfigValue is a sealed interface with 4 types: StringVal, IntVal, BoolVal, ListVal\n- Use pattern matching in switch expressions for type-specific processing\n\n※ Following the one-class-per-file principle, create: **ConfigValue.java**, **AppConfig.java**, **ConfigDemo.java**",
        "h": "Define sealed interface ConfigValue permits StringVal, IntVal, BoolVal, ListVal, and implement with records.",
        "x": "■ sealed interface\nLimits ConfigValue implementations to four types: StringVal, IntVal, BoolVal, ListVal. Enables exhaustive pattern matching in switch.\n\n■ record in sealed interface\nDefining records inside a sealed interface puts permits and data classes in one file.\n\n■ Builder pattern\nPrivate constructor + inner Builder class for incremental configuration construction."
    },

    # ===== Comprehensive Collections =====
    "comp_coll_01": {
        "d": "Create a grade management program with the following specifications.\n\n| File | GradeManager.java |\n|---|---|\n\n| Data Structure | Type | Description |\n|-----------|------|------|\n| Grade data | Map\\<String, List\\<Integer\\>\\> | Student name → score list |\n\n| Process | Description |\n|------|------|\n| Average calculation | Calculate each student's average across all subjects |\n| Highest average | Display the student with the highest average |\n| List display | Show all students' names, scores, and averages |",
        "h": "Use LinkedHashMap<String, List<Integer>> to preserve insertion order. Calculate average as sum ÷ count for each list.",
        "x": "■ LinkedHashMap<K,V>: A Map implementation that preserves insertion order.\n■ List.of(): A factory method that creates an immutable list (Java 9+).\n■ Map.Entry: An interface representing one entry (key-value pair) of a Map.\n■ stream().mapToInt().average(): A method chain for calculating averages with Stream.\n■ System.out.printf(): Formatted output. %.1f displays one decimal place."
    },
    "comp_coll_02": {
        "d": "Create a generics class with the following specifications.\n\n| File | PairDemo.java |\n|---|---|\n\n| Class | Type Params | Fields | Methods |\n|--------|------------|-----------|----------|\n| Pair\\<A, B\\> | A, B | first: A, second: B | getFirst(): A, getSecond(): B, swap(): Pair\\<B, A\\> |\n\nCreate a Pair\\<String, Integer\\> and output the swapped Pair\\<Integer, String\\>.\n\n※ Following the one-class-per-file principle, create: **Pair.java**, **PairDemo.java**",
        "h": "Define first (A type) and second (B type) fields in Pair<A,B>. swap() creates a new instance returning Pair<B,A>.",
        "x": "■ Multiple type parameters <A,B>: A generics class that accepts two different types.\n■ Type swapping: swap() returns Pair<B,A> for type-safe value swapping.\n■ toString(): Customizes the object's string representation. Automatically called by println().\n■ Diamond operator <>: new Pair<>(...) infers generics arguments via type inference."
    },
    "comp_coll_03": {
        "d": "Create an inventory management class with the following specifications.\n\n| File | InventoryDemo.java |\n|---|---|\n\n| Class | Data Structure | Description |\n|--------|-----------|------|\n| Inventory | Map\\<String, Integer\\> | Product name → stock count |\n\n| Method | Return | Description |\n|----------|--------|------|\n| addStock(String, int) | void | Stock in |\n| removeStock(String, int) | boolean | Stock out (false if insufficient) |\n| printInventory() | void | Display inventory list |\n| getOutOfStock() | List\\<String\\> | List of out-of-stock products |\n\n※ Following the one-class-per-file principle, create: **InventoryManager.java**, **Inventory.java**",
        "h": "Define addStock() and removeStock() methods to manage stock changes. Search for entries with value ≤ 0 for out-of-stock items.",
        "x": "■ LinkedHashMap: A Map preserving insertion order, making inventory display order predictable.\n■ getOrDefault(): Returns a default value when the key doesn't exist. Prevents NullPointerException.\n■ Math.max(0, v): Prevents stock from going negative by capping the lower bound at 0.\n■ ArrayList + loop: Dynamically collects out-of-stock products for list display."
    },
    "comp_coll_04": {
        "d": "Create a program that uses Set to find the intersection, union, and difference of two lists.\n\n[Required Knowledge] HashSet, retainAll, addAll, removeAll",
        "h": "Use Set's retainAll() for intersection, addAll() for union, removeAll() for difference. Make copies before operations since they modify the original Set.",
        "x": "■ TreeSet: A sorted set. Output order is predictable with numbers in ascending order.\n■ retainAll(Collection): Retains only elements contained in the specified collection (intersection).\n■ addAll(Collection): Adds all elements from the specified collection (union).\n■ removeAll(Collection): Removes all elements contained in the specified collection (difference).\n■ Importance of copying: Set operations are destructive, so copy with new TreeSet<>(list) before operating."
    },
    "comp_coll_05": {
        "d": "Create a generic method findAll() that searches for elements matching a condition in a list of any type. Verify it works with both Integer and String lists.\n\n[Required Knowledge] Generic methods, Predicate, List",
        "h": "Define as <T> List<T> findAll(List<T> list, Predicate<T> condition). Use Predicate.test() for condition checking.",
        "x": "■ Generic method <T>: Declares a type parameter at the method level; the type is inferred at call time.\n■ Predicate<T>: A functional interface that takes T and returns boolean.\n■ Lambda expression: n -> n % 2 == 0 concisely implements a Predicate.\n■ Type inference: T is inferred as Integer for findAll(numbers, ...) and String for findAll(words, ...)."
    },
    "comp_coll_06": {
        "d": "Implement an **LRU (Least Recently Used) cache**. When capacity is exceeded, the least recently accessed element is automatically removed.\n\n| Method | Return | Description |\n|---------|--------|------|\n| get(K key) | V | Gets value (updates access order) |\n| put(K key, V value) | void | Adds/updates value |\n| size() | int | Current element count |\n\n- Automatically remove oldest element when capacity is exceeded\n- Both get and put update access order",
        "h": "Use LinkedHashMap's accessOrder=true constructor, or implement with HashMap + doubly-linked list.",
        "x": "■ LinkedHashMap(capacity, loadFactor, accessOrder)\naccessOrder=true moves accessed elements to the end on get or put.\n\n■ removeEldestEntry()\nOverride this LinkedHashMap hook method to auto-remove the oldest element when capacity is exceeded.\n\n■ Generic class inheritance\nLRUCache<K, V> extends LinkedHashMap<K, V> for a general-purpose cache."
    },
    "comp_coll_07": {
        "d": "Create a program that sorts employee data by **compound conditions** and manages it as **immutable collections**.\n\n| File | Role |\n|-------------|------|\n| Employee.java | record (name, department, salary, joinYear) |\n| EmployeeAnalyzer.java | Main method + analysis logic |\n\n- Group by department\n- Sort by salary descending → join year ascending → name ascending\n- Return immutable lists with Collections.unmodifiableList\n- Output sort results and average salary by department\n\n※ Following the one-class-per-file principle, create: **Employee.java**, **EmployeeAnalyzer.java**",
        "h": "Chain Comparator.comparing().thenComparing() and use reversed() for descending order.",
        "x": "■ Compound Comparator\nChains Comparator.comparingInt().reversed().thenComparing() for multiple sort conditions.\n\n■ collectingAndThen\nPerforms two-step processing (collect then convert to immutable list) in a single collect().\n\n■ TreeMap as Supplier\nPassing TreeMap::new as the second argument to groupingBy() sorts keys in natural order."
    },

    # ===== Comprehensive Functional =====
    "comp_func_01": {
        "d": "Create a program using Stream to calculate total sales, the highest-priced product, and the number of products costing 1000 yen or more from a list of SaleRecords (product name and amount).\n\n[Required Knowledge] Stream, filter, map, reduce, max\n\n※ Following the one-class-per-file principle, create: **SaleRecord.java**, **SalesReport.java**",
        "h": "Use stream().mapToInt(SaleRecord::price).sum() for totals and max() for the maximum value.",
        "x": "■ record: A data class since Java 16. Fields, constructor, and getters are auto-generated.\n■ mapToInt(): Intermediate operation converting Stream<T> to IntStream.\n■ sum(): Terminal operation that calculates the sum of an IntStream.\n■ max() + Comparator: Retrieves the maximum element using a comparison function. Returns Optional.\n■ filter().count(): Counts elements matching the condition."
    },
    "comp_func_02": {
        "d": "Create a program that composes multiple Function<String,String> transformations (trim, uppercase, add prefix) using andThen() and applies them to a string list.\n\n[Required Knowledge] Function, andThen, Stream, map",
        "h": "Chain transformations with Function.andThen() and batch-apply with stream().map(composedFunction).",
        "x": "■ Function<T,R>: A functional interface that takes T and returns R.\n■ andThen(): A composition method that chains functions, applying left to right.\n■ Method reference (String::trim): A concise notation equivalent to lambda s -> s.trim().\n■ stream().map().forEach(): Chains transformation and output in a pipeline."
    },
    "comp_func_03": {
        "d": "Create a program that groups an employee list (name, department, age) using Stream API and aggregates the count and average age by department.\n\n[Required Knowledge] Collectors.groupingBy, Stream, Map\n\n※ Following the one-class-per-file principle, create: **Employee2.java**, **DepartmentReport.java**",
        "h": "Group by department with Collectors.groupingBy(), then calculate count() and average() from each group's list.",
        "x": "■ Collectors.groupingBy(): Groups Stream elements by a specified key into a Map.\n■ LinkedHashMap::new: Specifies the Map implementation as second argument to preserve insertion order.\n■ record: Concisely defines Employee2 data.\n■ mapToInt().average(): Calculates the average of a numeric stream. Returns Optional.\n■ printf + %n: Outputs a platform-dependent newline."
    },
    "comp_func_04": {
        "d": "Create a program that uses Stream's collect() to aggregate statistics (sum, average, max, min, count) from an integer list into Map<String,Number>.\n\n[Required Knowledge] Stream, Collectors, IntSummaryStatistics",
        "h": "IntSummaryStatistics lets you get sum, average, max, min, and count all at once.",
        "x": "■ IntSummaryStatistics: A class that manages sum, average, max, min, and count together.\n■ summaryStatistics(): A terminal operation that calculates statistics from IntStream at once.\n■ getCount/getSum/getAverage/getMax/getMin: Methods for retrieving each statistic.\n■ mapToInt(Integer::intValue): Converts Stream<Integer> → IntStream."
    },
    "comp_func_05": {
        "d": "Create a program that parses CSV-format string list and uses Stream API for: \"name,age,city\" → filter by condition → sort by age descending → formatted output.\n\n[Required Knowledge] Stream, map, filter, sorted, Comparator, split\n\n※ Following the one-class-per-file principle, create: **Person.java**, **CsvPipeline.java**",
        "h": "Split CSV with split(\",\"), convert to record Person, and process with Stream. Use Comparator.comparingInt() for age sorting.",
        "x": "■ map(): Intermediate operation converting CSV strings to Person records.\n■ filter(): Filters for age 30 and above.\n■ sorted() + reversed(): Creates an ascending Comparator then reverses for descending.\n■ forEach(): Terminal operation that outputs each element.\n■ Stream pipeline: Declaratively describes the processing chain of map→filter→sorted→forEach."
    },
    "comp_func_06": {
        "d": "Build a string encryption/decryption pipeline using **Function composition (compose / andThen)**.\n\n| Transform Step | Process |\n|-------------|------|\n| Step 1 | Add +3 to each character's ASCII code (Caesar cipher) |\n| Step 2 | Reverse the string |\n| Step 3 | Base64 encode |\n\n- Build encryption pipeline (Step1 → Step2 → Step3) with Function composition\n- Also build decryption pipeline (reverse Step3 → reverse Step2 → reverse Step1)\n- Verify that encrypting then decrypting returns the original string",
        "h": "Chain Functions with andThen(). Prepare inverse functions for each step.",
        "x": "■ Function.andThen()\nChains functions sequentially. f.andThen(g) is equivalent to g(f(x)).\n\n■ Reversible transformations\nPrepares inverse functions for each step to build the decryption pipeline. Caesar cipher inverse of +3 is -3.\n\n■ Method reference vs lambda\nStatic methods returning Functions create a factory pattern for flexible pipeline assembly."
    },
    "comp_func_07": {
        "d": "Implement the following custom Collectors using **Collector.of()**.\n\n| Collector | Description |\n|-----------|------|\n| toStats() | Collects sum, average, max, min, count into a Statistics object |\n| topN(n) | Collects top N items in descending order as a List |\n\n- Apply to Integer streams\n- toStats() implements all of Collector.of()'s supplier / accumulator / combiner / finisher\n- topN() uses PriorityQueue for efficient top-N collection",
        "h": "Build with Collector.of(() -> new Stats(), (stats, val) -> stats.accept(val), (s1, s2) -> s1.combine(s2), stats -> stats.build()).",
        "x": "■ Collector.of()'s four components\nSpecify supplier (initialization), accumulator (accumulation), combiner (parallel combining), finisher (final transform).\n\n■ PriorityQueue (min-heap)\ntopN() uses a min-heap, keeping at most N elements. The smallest is removed first, leaving the top N.\n\n■ combiner\nImplements logic for combining two intermediate results for parallel Stream support."
    },

    # ===== Comprehensive DB & Web =====
    "comp_dbweb_01": {
        "d": "Design an employee table (id, name, department, salary) and write a program with INSERT, SELECT, UPDATE, DELETE SQL statements.\n\n[Required Knowledge] CREATE TABLE, INSERT, SELECT, UPDATE, DELETE, WHERE",
        "h": "Set a PRIMARY KEY in CREATE TABLE and write each CRUD operation in order.",
        "x": "■ CREATE TABLE: A DDL statement defining columns, types, and constraints for a table.\n■ PRIMARY KEY: A constraint that uniquely identifies each row.\n■ INSERT INTO: A DML statement for adding data. Values are specified in the VALUES clause.\n■ SELECT ... WHERE: A DML statement for querying data matching conditions.\n■ UPDATE ... SET ... WHERE: A DML statement for updating data matching conditions.\n■ DELETE FROM ... WHERE: A DML statement for deleting data matching conditions."
    },
    "comp_dbweb_02": {
        "d": "Create a program skeleton for connecting to a database with JDBC and executing parameterized queries with PreparedStatement. Manage resources safely with try-with-resources.\n\n[Required Knowledge] DriverManager, Connection, PreparedStatement, ResultSet, try-with-resources",
        "h": "Connect with DriverManager.getConnection() and bind values to PreparedStatement's ? placeholders with setXxx().",
        "x": "■ DriverManager.getConnection(): Establishes a DB connection by specifying a URL.\n■ Connection: An interface representing a database connection. Implements AutoCloseable.\n■ PreparedStatement: Safely binds parameters with ? placeholders (prevents SQL injection).\n■ setInt(position, value): Binds a value to the ? at the specified position (1-based).\n■ ResultSet: Reads SELECT results row by row. Use next() to advance to the next row.\n■ try-with-resources: Auto-closes Connection, Statement, and ResultSet."
    },
    "comp_dbweb_03": {
        "d": "Create a Spring Boot REST controller with the following specifications.\n\n| File | ProductController.java |\n|---|---|\n\n| Endpoint | HTTP Method | Path | Description |\n|--------------|------------|------|----- |\n| Get all | GET | /api/products | Returns product list |\n| Get one | GET | /api/products/{id} | Searches by ID |\n| Create | POST | /api/products | Registers new product |\n| Delete | DELETE | /api/products/{id} | Deletes product |",
        "h": "Use the annotation corresponding to each HTTP method. Receive path parameters with @PathVariable.",
        "x": "■ @RestController: Annotation for REST API controllers. Includes @ResponseBody.\n■ @RequestMapping: Specifies the base URL path. Combines with method-level mappings.\n■ @GetMapping / @PostMapping / @DeleteMapping: Defines handlers for each HTTP method.\n■ @PathVariable: Binds the {id} part of the URL path to a method argument.\n■ @RequestBody: Converts the HTTP request body JSON to an object."
    },
    "comp_dbweb_04": {
        "d": "Implement bank transfer processing with JDBC transactions. Rollback on insufficient source balance, commit on success.\n\n[Required Knowledge] Connection.setAutoCommit, commit, rollback, PreparedStatement",
        "h": "Start a transaction with conn.setAutoCommit(false), call commit() on success and rollback() on failure.",
        "x": "■ setAutoCommit(false): Disables auto-commit, switching to manual transaction management.\n■ commit(): Applies all changes within the transaction to the database.\n■ rollback(): Rolls back all changes within the transaction to the state before the transaction started.\n■ try-catch-finally: A pattern for rollback on exception, commit on success, and restore autoCommit at the end."
    },
    "comp_dbweb_05": {
        "d": "Create a unified format class for API responses.\n\n| File | ApiResponseDemo.java |\n|---|---|\n\n| Class | Type Param | Fields | Description |\n|--------|------------|-----------|------|\n| ApiResponse\\<T\\> | T | status: int, message: String, data: T | Unified response |\n\n| Factory Method | Return | Description |\n|-------------------|--------|------|\n| success(T data) | ApiResponse\\<T\\> | Success response (status=200) |\n| error(String msg) | ApiResponse\\<T\\> | Error response (status=500) |\n\n※ Following the one-class-per-file principle, create: **ApiResponse.java**, **Product.java**, **ApiResponseDemo.java**",
        "h": "Define status, message, data fields in ApiResponse<T> and provide success() and error() factory methods.",
        "x": "■ Generic class <T>: Allows the response's data field to be any type.\n■ Factory methods: Unifies instance creation with success()/error(), making the constructor private.\n■ record: Concise Product data definition (Java 16+). Auto-generates constructor, getters, equals, hashCode.\n■ null usage: Distinguishes success/error type-safely with data=null for errors."
    },
    "comp_dbweb_06": {
        "d": "Design a data access layer using the **DAO (Data Access Object) pattern**. Make in-memory and JDBC implementations switchable.\n\n| File | Role |\n|-------------|------|\n| User.java | User entity (record) |\n| UserDao.java | CRUD interface |\n| InMemoryUserDao.java | In-memory implementation using Map |\n| DaoDemo.java | Main method |\n\n- Define findById / findAll / save / delete in UserDao\n- Use Optional for safe access to non-existent IDs\n\n※ Following the one-class-per-file principle, create: **User.java**, **UserDao.java**, **InMemoryUserDao.java**, **DaoDemo.java**",
        "h": "Define CRUD methods in the UserDao interface and implement with Map<Integer, User> in InMemoryUserDao.",
        "x": "■ DAO pattern\nAbstracts data access logic with an interface, enabling switchable implementations (in-memory/JDBC/file).\n\n■ Optional\nfindById() returns Optional, enabling safe access without null checks.\n\n■ List.copyOf()\nDefensive copy that prevents external modification."
    },

    # ===== Comprehensive Concurrency =====
    "comp_conc_01": {
        "d": "Create a 10-second countdown timer displayed on the console using Thread.sleep(). Run the countdown in a separate thread.\n\n[Required Knowledge] Thread, Runnable, sleep, InterruptedException",
        "h": "Implement the countdown logic with Runnable and use Thread.sleep(1000) to wait 1 second.",
        "x": "■ Runnable: A functional interface with run(). Can be concisely implemented with lambda.\n■ new Thread(runnable): Creates a thread by passing a Runnable.\n■ start(): Starts the thread. Calling run() directly executes in the same thread.\n■ Thread.sleep(1000): Pauses the current thread for 1000 milliseconds (1 second).\n■ join(): Waits for thread completion. Main thread waits for timer to finish."
    },
    "comp_conc_02": {
        "d": "Create a program that writes to and reads from a text file using java.nio.file.Files. Display content with line numbers.\n\n[Required Knowledge] Files.write, Files.readAllLines, Path, StandardCharsets",
        "h": "Write List<String> with Files.write() and read all lines with Files.readAllLines().",
        "x": "■ Path.of(): Static method for creating file paths (Java 11+).\n■ Files.write(): Writes data (List<String>) to a Path. Character encoding can be specified.\n■ Files.readAllLines(): Reads all file lines as List<String>.\n■ StandardCharsets.UTF_8: Character encoding constant. Handles multibyte characters correctly.\n■ Files.deleteIfExists(): Deletes a file if it exists."
    },
    "comp_conc_03": {
        "d": "Create a program that safely increments a counter from multiple threads. Show the difference between using and not using synchronized.\n\n[Required Knowledge] Thread, synchronized, AtomicInteger",
        "h": "10 threads each increment 1000 times. Use synchronized methods or AtomicInteger.incrementAndGet() for thread safety.",
        "x": "■ synchronized: When applied to a method, allows exclusive access by one thread at a time (mutual exclusion).\n■ AtomicInteger: A class providing lock-free thread-safe integer operations.\n■ incrementAndGet(): Atomically increments the value by 1 and returns the new value.\n■ Thread.join(): Waits for thread completion, synchronizing the timing for checking results.\n■ Race condition: Without synchronized, multiple threads updating simultaneously can lose values."
    },
    "comp_conc_04": {
        "d": "Create a program that lists files in a specified directory, groups them by extension, and displays with size information.\n\n[Required Knowledge] Files.walk, Stream, Path, BasicFileAttributes, Collectors.groupingBy",
        "h": "Recursively explore directories with Files.walk() and group by extension with stream's groupingBy. Get sizes with Files.size().",
        "x": "■ Files.walk(): Recursively explores directories and returns Stream<Path>. Use with try-with-resources.\n■ Files::isRegularFile: A method reference filtering regular files (not directories).\n■ Collectors.groupingBy(): Groups files by extension as the key.\n■ Files.size(): Returns the file's byte count.\n■ Stream + Map + functional: Declaratively processes exploration, classification, and aggregation in a Stream pipeline."
    },
    "comp_conc_05": {
        "d": "Create a program that executes multiple tasks in parallel using ExecutorService and receives results via Future<T>. Each task simulates different processing times.\n\n[Required Knowledge] ExecutorService, Callable, Future, newFixedThreadPool",
        "h": "Create a thread pool with Executors.newFixedThreadPool(), submit Callable<T> tasks, and manage with a list of Future<T>.",
        "x": "■ Executors.newFixedThreadPool(n): Creates a thread pool with n threads.\n■ Callable<T>: A task that returns a value. Unlike Runnable, can return and throw exceptions.\n■ submit(Callable): Submits a task to the thread pool and returns a Future<T>.\n■ Future.get(): A blocking method that waits for task completion and retrieves the result.\n■ executor.shutdown(): Stops accepting new tasks and waits for running tasks to complete."
    },
    "comp_conc_06": {
        "d": "Implement the **Producer-Consumer** pattern using BlockingQueue.\n\n| File | Role |\n|-------------|------|\n| Task.java | Task data (record) |\n| Producer.java | Thread that puts tasks on the queue |\n| Consumer.java | Thread that takes and processes tasks |\n| ProducerConsumerDemo.java | Main method |\n\n- Producer generates 5 tasks then puts a stop signal (POISON PILL)\n- Consumer stops upon receiving the stop signal\n- Queue maximum capacity is 3\n\n※ Following the one-class-per-file principle, create: **Task.java**, **Producer.java**, **Consumer.java**, **ProducerConsumerDemo.java**",
        "h": "Share ArrayBlockingQueue<Task>(3) between Producer and Consumer. Use a special Task instance (POISON_PILL) as the stop signal.",
        "x": "■ BlockingQueue\nput() blocks when the queue is full; take() blocks when empty. Automatically synchronizes between threads.\n\n■ POISON PILL pattern\nPuts a special object (POISON_PILL) in the queue to notify the Consumer to stop.\n\n■ record's static field\nDefines Task.POISON_PILL as a static field in the record, representing the stop signal with a single instance."
    },
    "comp_conc_07": {
        "d": "Build an order processing pipeline chaining multiple asynchronous operations using **CompletableFuture**.\n\n| Processing Step | Duration | Description |\n|-------------|---------|------|\n| Stock check | 300ms | Check product inventory |\n| Price calculation | 200ms | Calculate discounted price |\n| Payment processing | 500ms | Process payment |\n\n- Chain each step with CompletableFuture.supplyAsync() / thenApplyAsync()\n- Use exceptionally() for fallback values on errors\n- Process 3 products in parallel, wait with allOf()",
        "h": "Pass results to the next step with thenApplyAsync() and handle errors with exceptionally(). Wait for all with CompletableFuture.allOf().",
        "x": "■ CompletableFuture chain\nBuilds a 3-stage pipeline with supplyAsync → thenApplyAsync → thenApplyAsync.\n\n■ exceptionally()\nDefines fallback processing when an exception occurs mid-pipeline.\n\n■ CompletableFuture.allOf()\nWaits for multiple CompletableFutures to complete in parallel. join() blocks until done."
    },

    # ===== Comprehensive Modules =====
    "comp_mod_01": {
        "d": "Design the dependencies of 3 modules (app, service, model) and write the content of each module-info.java.\n\n[Required Knowledge] module declaration, requires, exports",
        "h": "Design dependencies as model → service → app. Using requires transitive allows app to also reference model.",
        "x": "■ module declaration: Defines a module with module moduleName { }.\n■ exports: Makes a package available to other modules.\n■ requires: Declares dependency on another module.\n■ requires transitive: Transitive dependency. When service transitively requires model, app can also use model.\n■ Text blocks: Uses \"\"\"...\"\"\" for readable multiline strings."
    },
    "comp_mod_02": {
        "d": "Create a program that switches greeting text in Japanese, English, and French based on locale using Locale and ResourceBundle (Map alternative is OK).\n\n[Required Knowledge] Locale, ResourceBundle (concept), Map, switch",
        "h": "Manage per-locale messages with Map<Locale, Map<String, String>> and retrieve with getOrDefault().",
        "x": "■ Locale: A class representing language, country, and region. Has constants like Locale.JAPANESE, Locale.ENGLISH.\n■ getLanguage(): Returns the locale's language code (\"ja\", \"en\", etc.).\n■ Map.of(): Factory method for creating immutable Maps (Java 9+).\n■ getOrDefault(): Returns a default value when the key doesn't exist. Used for unsupported locale fallback.\n■ ResourceBundle concept: In real apps, language-specific resources are managed in properties files."
    },
    "comp_mod_03": {
        "d": "Create a program that displays the same amount in three currency formats (Japanese yen, US dollar, Euro) using NumberFormat.\n\n[Required Knowledge] NumberFormat, Locale, getCurrencyInstance, format",
        "h": "Get locale-specific formatters with NumberFormat.getCurrencyInstance(Locale.country).",
        "x": "■ NumberFormat.getCurrencyInstance(Locale): Gets a currency formatter appropriate for the locale.\n■ format(double): Converts a number to currency-formatted string. Currency symbol and digit separators are automatically applied.\n■ Locale.JAPAN: Japanese locale (currency: ¥, no decimals).\n■ Locale.US: US locale (currency: $, 2 decimal places).\n■ Locale.GERMANY: German locale (currency: €, comma and dot are reversed vs Japan)."
    },
    "comp_mod_04": {
        "d": "Create a program that displays the same datetime in different formats across multiple locales (Japan, US, France). Consider timezone differences.\n\n[Required Knowledge] ZonedDateTime, DateTimeFormatter, Locale, ZoneId",
        "h": "Create timezone-aware datetime with ZonedDateTime.of() + ZoneId and convert to other timezones with withZoneSameInstant().",
        "x": "■ ZonedDateTime: A datetime class with timezone. Essential for internationalized apps.\n■ ZoneId.of(): Specifies a timezone (\"Asia/Tokyo\", \"America/Chicago\", etc.).\n■ withZoneSameInstant(): Expresses the same instant in a different timezone.\n■ DateTimeFormatter.ofPattern(): Defines formatting with a pattern string and locale.\n■ Locale argument: Outputs day names (EEEE) and month names (MMM) in the locale's language."
    },
    "comp_mod_05": {
        "d": "Design a system that returns multilingual error messages based on error codes. Support Japanese and English, returning a default message for unsupported error codes.\n\n[Required Knowledge] Locale, Map, enum, Optional\n\n※ Following the one-class-per-file principle, create: **ErrorCode.java**, **ErrorMessageSystem.java**",
        "h": "Define error codes with enum and map with Map<Locale, Map<ErrorCode, String>> for multilingual messages.",
        "x": "■ enum ErrorCode: An enum that defines error codes in a type-safe manner.\n■ ErrorCode.values(): Returns all enum constants as an array.\n■ Map<String, Map<ErrorCode, String>>: A two-level Map (language → code → message) for i18n.\n■ getOrDefault(): Used for fallback to English for unsupported languages.\n■ Locale.getLanguage(): Gets language codes like \"ja\", \"en\" for use as Map keys."
    },
    "comp_mod_06": {
        "d": "Create a program that manages multilingual configuration messages using **ResourceBundle**.\n\nSwitch between Japanese and English messages at runtime.\n\n| Locale | Filename | Greeting | Error Message |\n|---------|-----------|------|----------------|\n| ja_JP | messages_ja_JP.properties | Welcome | Invalid input |\n| en_US | messages_en_US.properties | Welcome | Invalid input |\n\n- Catch MissingResourceException for non-existent keys and return a default value\n- Simulate property files in code",
        "h": "Inherit ListResourceBundle to define resources in program without .properties files.",
        "x": "■ ListResourceBundle\nDefines resources in a Java class instead of property files. Returns a 2D array from getContents().\n\n■ ResourceBundle.getBundle()\nSpecifies a base name and Locale to find classes by naming convention like MessageBundle_ja_JP.class.\n\n■ MissingResourceException\nThrown when accessing a non-existent key. Catching and returning a default value is a common real-world pattern."
    },
}
