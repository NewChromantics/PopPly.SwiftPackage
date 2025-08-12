import Foundation
import simd


public struct PlyError : LocalizedError
{
	var message : String
	
	public init(_ message:String)
	{
		self.message = message
	}
	
	public var errorDescription: String?	{	message	}
}


public struct PlyPoint
{
	static public var propertyNames : [String]
	{
		return ["x","y","z","red","green","blue"]
	}
	//var values : [Float] = [0,0,0,0,0,0]
	public var values : [Float]	{	[x,y,z,r,g,b]	}
	public var x : Float = 0
	public var y : Float = 0
	public var z : Float = 0
	public var r : Float = 0
	public var g : Float = 0
	public var b : Float = 0
	static public var sizeBytes : Int		{	MemoryLayout<PlyPoint>.stride	}
	static public var sizeMegaBytes : Float	{	Float(sizeBytes) / 1024.0 / 1024.0	}
	public var xyz : simd_float3	{	simd_float3(x,y,z)	}
	
	public init()
	{
	}

	public init(xyz:simd_float4,rgb:simd_float3)
	{
		x = xyz.x
		y = xyz.y
		z = xyz.z
		r = rgb.x
		g = rgb.y
		b = rgb.z
	}
}


public class PlyWriter
{
	private var header : String = ""	//	accumulate the header string
	//	all data, once allocated, it means we've put the header in
	public var headerFinished : Bool	{	data != nil	}
	private var data : Data? = nil
	public var dataSizeMbString : String	{	String(format: "%.2f", dataSizeMb)	}
	public var dataSizeMb : Float		{	Float(data.map{ $0.count } ?? header.count) / (1024.0*1024.0)	}
	
	public init()
	{
		//	these should never throw
		try! AddHeader("ply")
		try! AddHeader("format binary_little_endian 1.0")
	}
	
	public func GetData() throws -> Data
	{
		//	gr: allow no data here when no points written, but have a valid header
		guard let data else 
		{
			throw PLYTypeError("No data was written")
		}
		return data
	}
	
	public func AddComment(_ comment:String) throws
	{
		//	santiise comment by turning line feeds into new comment lines
		let commentLines = comment.components(separatedBy: "\n")
		try commentLines.forEach
		{
			try AddHeader("comment \($0)")
		}
	}
	
	//	very brute force atm
	public func AddHeader(_ headerLine:String) throws
	{
		if headerFinished
		{
			throw PlyError("Trying to add header to PLY after we've started adding data")
		}
		header += headerLine
		header += "\n"
	}
	
	public func EndHeader() throws
	{
		//	already ended
		if headerFinished
		{
			return
		}
		try AddHeader("end_header")
		self.data = header.data(using: .utf8)
	}
	
	
	public func AddData(points:[PlyPoint]) throws
	{
		//	todo: verify elment count matches header
		var data = try self.data ?? {	try EndHeader();	return self.data!	}()
		
		var p = points
		let pointData = Data(bytes: &p,count: MemoryLayout<PlyPoint>.stride * points.count)
		
		self.data!.append(pointData)
	}
	
	public func AddData(point:PlyPoint) throws
	{
		//	todo: verify elment count matches header
		var data = try self.data ?? {	try EndHeader();	return self.data!	}()
		
		var p = point
		let pointData = Data(bytes: &p,count: MemoryLayout<PlyPoint>.stride)
		
		self.data!.append(pointData)
	}
}
