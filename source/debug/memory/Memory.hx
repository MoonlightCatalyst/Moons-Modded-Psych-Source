package debug.memory;

/**
 * Memory class to properly get accurate memory counts for the program.
 * If you are not running on a CPP Platform, the code just will not work properly, sorry!

 * @author Leather128 (Haxe) - David Robert Nadeau (Original C Header)
 */
@:publicFields
#if cpp
@:buildXml('<include name="../../../../source/debug/memory/build.xml"/>')
@:include('memory.h')
extern
#end
class Memory
{
	/**
	 * Returns the peak (maximum so far) resident set size (physical
	 * memory use) measured in bytes, or zero if the value cannot be
	 * determined on this OS.

	 * (Non cpp platform)
	 * Returns 0.
	 */
	#if cpp @:native('getPeakRSS') #end static function getPeakUsage():Float;

	/**
 	 * Returns the current resident set size (physical memory use) measured
 	 * in bytes, or zero if the value cannot be determined on this OS.

	 * (Non cpp platform)
	 * Returns 0.
	 */
	#if cpp @:native('getCurrentRSS') #end static function getCurrentUsage():Float;
}