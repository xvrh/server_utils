void main() {
  // - Generate all the classes to insert/update/query all the table from the schema
  // - The configuration in this file allows to exclude or customize some of the generation (ie: enum type etc..).
  // - Generate all metadata about the tables so we can use constant to build queries
  // - Generate one class for each "queries.sql" file with all the methods to execute the query
  //    The generated code should expose the raw SQL so it can be wrapped in other method (like Pager).
  // - All the generated classes are separated from api classes (with fromJson, toJson)..
  //    but we create a Mapper builder able to generate the code to convert one to another
  //    using sensible defaults and validation.
  //    Generated classes from table also include fromJson & toJson.
}
