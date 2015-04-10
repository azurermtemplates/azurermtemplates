/*
 * Credit for a nice simple example goes to alvin http://www.valleyprogramming.com/blog/simple-hadoop-mapreduce-tutorial-example-boulder-colorado
 *
 */

package hadoopwordcount;

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class WordCount {

  public static class WordTokenizerMapper 
  extends Mapper<Object, Text, Text, IntWritable>
  {
    
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
      
    /**
     * map() gets a key, value, and context (which we'll ignore for the moment).
     * key - seems to be "bytes from the beginning of the file"
     * value - the current line; we are being fed one line at a time from the 
     *         input file
     * 
     * here's what the key and value look like if i print them out with the first
     * println statement below:
     * 
     * [map] key: (0), value: ([Weekly Compilation of Presidential Documents])
     * [map] key: (47), value: (From the 2002 Presidential Documents Online via GPO Access [frwais.access.gpo.gov])
     * [map] key: (130), value: ([DOCID:pd04fe02_txt-11]                         )
     * [map] key: (179), value: ()
     * [map] key: (180), value: ([Page 133-139])
     * 
     * in the tokenizer loop, each token is a "word" from the current line, so the first token from
     * the first line is "Weekly", then "Compilation", and so on. as a result, the output from the loop
     * over the first line looks like this:
     * 
     * [map] key: (0), value: ([Weekly Compilation of Presidential Documents])
     * [map, in loop] token: ([Weekly)
     * [map, in loop] token: (Compilation)
     * [map, in loop] token: (of)
     * [map, in loop] token: (Presidential)
     * [map, in loop] token: (Documents])
     * 
     */
    public void map(Object key, 
    		            Text value, 
    		            Context context) 
    throws IOException, InterruptedException
    {
      //System.err.println(String.format("[map] key: (%s), value: (%s)", key, value));
      // break each sentence into words, using the punctuation characters shown
      StringTokenizer tokenizer = new StringTokenizer(value.toString(), " \t\n\r\f,.:;?![]'");
      while (tokenizer.hasMoreTokens())
      {
        // make the words lowercase so words like "an" and "An" are counted as one word
        String s = tokenizer.nextToken().toLowerCase().trim();
        System.err.println(String.format("[map, in loop] token: (%s)", s));
        word.set(s);
        context.write(word, one);
      }
    }
  }
  
  /**
   * this is the reducer class.
   * some magic happens before the data gets to us. the key and values data looks like this:
   * 
   * [reduce] key: (Afghan), value: (1)
   * [reduce] key: (Afghanistan), value: (1, 1, 1, 1, 1, 1, 1)
   * [reduce] key: (Afghanistan,), value: (1, 1, 1)
   * [reduce] key: (Africa), value: (1, 1)
   * [reduce] key: (Al), value: (1)
   * 
   * there are also many '0' values in the data:
   * 
   * [reduce] key: (while), value: (0)
   * [reduce] key: (who), value: (0)
   * ...
   * 
   * note that the input to this function is sorted, so it begins with numbers, 
   * like "000", then starts with "a", "about", and so on, after the numbers are printed.
   *
   */
  public static class WordOccurrenceReducer 
  extends Reducer<Text, IntWritable, Text, IntWritable> 
  {
    private IntWritable occurrencesOfWord = new IntWritable();

    public void reduce(Text key, 
    		               Iterable<IntWritable> values, 
                       Context context) 
    throws IOException, InterruptedException
    {
      // debug output
      //printKeyAndValues(key, values);
      // the actual reducer work
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      occurrencesOfWord.set(sum);
      // this writes the word and the count, like this: ("Africa", 2)
      context.write(key, occurrencesOfWord);
      // my debug output
      System.err.println(String.format("[reduce] word: (%s), count: (%d)", key, occurrencesOfWord.get()));
    }

    // a little method to print debug output
    private void printKeyAndValues(Text key, Iterable<IntWritable> values) 
    {
      StringBuilder sb = new StringBuilder();
      for (IntWritable val : values)
      {
        sb.append(val.get() + ", ");
      }
      System.err.println(String.format("[reduce] key: (%s), value: (%s)", key, sb.toString()));
    }
  }

  /**
   * the "driver" class. it sets everything up, then gets it started.
   */
  public static void main(String[] args) 
  throws Exception 
  {
    Configuration conf = new Configuration();
    String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
    if (otherArgs.length != 2) 
    {
      System.err.println("Usage: wordcount <inputFile> <outputDir>");
      System.exit(2);
    }
    Job job = new Job(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(WordTokenizerMapper.class);
    job.setCombinerClass(WordOccurrenceReducer.class);
    job.setReducerClass(WordOccurrenceReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
    FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
