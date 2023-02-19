#
#	Sound Bank by あるる（きのもと 結衣） @arlez80
#
#	MIT License

class_name Bank

#extends Resource

const drum_track_bank:int = 128

# 音色
class Instrument:
	var array_base_pitch:Array	# これは本当はPackedFloat32Arrayなんだけど、参照型ではなく値型らしく、代入だけでメモリ使用量が爆発してしまう
	var array_stream:Array		# AudioStreamWAV[]
	var ads_state:Array			# VolumeState[]
	var release_state:Array		# VolumeState[]
	var volume_db:float = 0.0
	var vel_range_min:int = 0
	var vel_range_max:int = 127
	var preset:Preset
	# var assine_group:int = 0	# reserved

	# 遅くなるので初期設定を削除
	#func _init():
	#	self.ads_state = [
	#		VolumeState.new( 0.0, 0.0 ),
	#		VolumeState.new( 0.2, -144.0 )
	#	]
	#	self.release_state = [
	#		VolumeState.new( 0.0, 0.0 ),
	#		VolumeState.new( 0.01, -144.0 )
	#	]

# 音量
class VolumeState:
	var time:float = 0.0
	var volume_db:float = 0.0

	func _init(_time:float = 0.0,_volume_db:float = 0.0):
		self.time = _time
		self.volume_db = _volume_db

# プリセット
class Preset:
	var name:String = ""
	var number:int = 0
	var instruments:Array = Array( )	# Instrument[]
	var bags:Array = Array( )			# TempSoundFontInstrumentBag[]

	func _init():
		for i in range( 128 ):
			self.instruments.append( null )

# SoundFont解析用
class TempSoundFontBag:
	var preset:Preset
	var coarse_tune:int
	var fine_tune:int
	var key_range:TempSoundFontRange
	var instrument:TempSoundFontInstrument
	var pan:float = 0.5

# SoundFont解析用
class TempSoundFontInstrument:
	var name:String = ""
	var bags:Array = Array( )	# TempSoundFontBag[]

# SoundFont解析用
class TempSoundFontRange:
	var low:int
	var high:int

	func _init(_low:int = 0,_high:int = 127):
		self.low = _low
		self.high = _high

	func duplicate( ) -> TempSoundFontRange:
		var new:TempSoundFontRange = TempSoundFontRange.new( )
		new.low = self.low
		new.high = self.high

		return new

# SoundFont解析用
class TempSoundFontInstrumentBag:
	var sample:SoundFont.SoundFontSampleHeader
	var sample_id:int = -1
	var sample_start_offset:int = 0
	var sample_end_offset:int = 0
	var sample_start_loop_offset:int = 0
	var sample_end_loop_offset:int = 0
	var coarse_tune:int = 0
	var fine_tune:int = 0
	var original_key:int = 255
	var keynum:int = 0
	var sample_modes:int = -1
	var key_range:TempSoundFontRange = TempSoundFontRange.new( 0, 127 )
	var vel_range:TempSoundFontRange = TempSoundFontRange.new( 0, 127 )
	var volume_db:float = 0.0
	var adsr:TempSoundFontInstrumentBagADSR = TempSoundFontInstrumentBagADSR.new( )

	func duplicate( ) -> TempSoundFontInstrumentBag:
		var new:TempSoundFontInstrumentBag = TempSoundFontInstrumentBag.new( )
		new.sample = self.sample
		new.sample_id = sample_id
		new.sample_start_offset = sample_start_offset
		new.sample_end_offset = sample_end_offset
		new.sample_start_loop_offset = sample_start_loop_offset
		new.sample_end_loop_offset = sample_end_loop_offset
		new.coarse_tune = coarse_tune
		new.fine_tune = fine_tune
		new.original_key = original_key
		new.keynum = keynum
		new.key_range = key_range.duplicate( )
		new.vel_range = vel_range.duplicate( )
		new.volume_db = volume_db
		new.adsr = adsr.duplicate( )

		return new

# SoundFont解析用
class TempSoundFontInstrumentBagADSR:
	var attack_vol_env_time:float = 0.001	# sec
	var decay_vol_env_time:float = 0.001	# sec
	var sustain_vol_env_db:float = 0.0		# dB
	var release_vol_env_time:float = 0.001	# sec

	func duplicate( ) -> TempSoundFontInstrumentBagADSR:
		var new:TempSoundFontInstrumentBagADSR = TempSoundFontInstrumentBagADSR.new( )
		new.attack_vol_env_time = self.attack_vol_env_time
		new.decay_vol_env_time = self.decay_vol_env_time
		new.sustain_vol_env_db = self.sustain_vol_env_db
		new.release_vol_env_time = self.release_vol_env_time

		return new

# 音色テーブル
@export var presets:Dictionary = Dictionary( )
# 頭の無音
const head_silent_samples:int = 44100 / 8
const head_silent_second:float = 1.0 / 8.0
var head_silent:PackedByteArray = PackedByteArray([])

func set_preset_sample( program_number:int, base_sample:int, base_key:int ) -> void:
	#
	# プリセットに波形を追加する
	# @param	program_number	プログラム番号
	# @param	base_sample		基準のサンプリング周波数
	# @param	base_key		基準のキー番号
	#

	var preset:Preset = Preset.new( )
	preset.name = "#%03d" % program_number
	preset.number = program_number
	for i in range( 0, 128 ):
		var inst:Instrument = Instrument.new( )
		inst.array_base_pitch = PackedFloat32Array( [ float( i - base_key ) / 12.0 ] )
		inst.array_stream = [ base_sample ]
		inst.preset = preset
		preset.instruments[i] = inst

	self.set_preset( program_number, preset )

func set_preset( program_number:int, preset:Preset ) -> void:
	#
	# プリセットを追加する
	# @param	program_number	プログラム番号
	# @param	preset			プリセットデータ
	#

	self.presets[program_number] = preset

func get_preset( program_number:int, bank:int = 0 ) -> Preset:
	#
	# 指定した楽器を取得
	# @param	program_number	プログラム番号
	# @param	bank			バンク番号
	#

	var pc:int = program_number | ( bank << 7 )

	# 存在しない場合
	if not self.presets.has( pc ):
		if self.drum_track_bank == bank:
			# ドラムの場合（Standard Kitを選択）
			pc = self.drum_track_bank << 7
		else:
			# 通常楽器の場合（Bank #0を選択）
			pc = program_number
		# それでも存在しない場合
		if not self.presets.has( pc ):
			if self.presets.is_empty( ): push_error( "Bank is empty." )
			# 一番最初のデフォルト音源を読む
			pc = self.presets.keys( )[0]

	return self.presets[pc]

func read_soundfont( sf:SoundFont.SoundFontData, need_program_numbers:Array = [] ) -> void:
	#
	# サウンドフォント読み込み
	# @param	sf:	サウンドフォントデータ
	# @param	needs_program_numbers		指定した番号のプログラム番号のみ読み込む
	#

	var sf_insts:Array = self._read_soundfont_pdta_inst( sf )

	if self.head_silent.size( ) == 0:
		var temp:Array = []
		for i in range( self.head_silent_samples * 2 ):
			temp.append( 0 )
		self.head_silent = PackedByteArray( temp )

	#var times:Array = []
	#times.append( Time.get_ticks_msec( ) )

	var bag_index:int = 0
	var gen_index:int = 0
	for phdr_index in range( 0, len( sf.pdta.phdr )-1 ):
		var phdr:SoundFont.SoundFontPresetHeader = sf.pdta.phdr[phdr_index]

		var preset:Preset = Preset.new( )
		var program_number:int = phdr.preset | ( phdr.bank << 7 )

		preset.name = phdr.name
		preset.number = program_number

		var bag_next:int = sf.pdta.phdr[phdr_index+1].preset_bag_index
		for bag_count in range( bag_index, bag_next ):
			var gen_next:int = sf.pdta.pbag[bag_count+1].gen_ndx
			var bag:TempSoundFontBag = TempSoundFontBag.new( )
			bag.preset = preset
			for gen_count in range( gen_index, gen_next ):
				var gen:SoundFont.SoundFontGenerator = sf.pdta.pgen[gen_count]
				match gen.gen_oper:
					SoundFont.gen_oper_coarse_tune:
						bag.coarse_tune = gen.amount
					SoundFont.gen_oper_fine_tune:
						bag.fine_tune = gen.amount
					SoundFont.gen_oper_key_range:
						bag.key_range = TempSoundFontRange.new( gen.uamount & 0xFF, gen.uamount >> 8 )
					SoundFont.gen_oper_pan:
						bag.pan = float( gen.amount + 500 ) / 1000.0
					SoundFont.gen_oper_instrument:
						bag.instrument = sf_insts[gen.uamount]
			if bag.instrument != null:
				preset.bags.append( bag )
			gen_index = gen_next
		bag_index = bag_next

		# 追加するか？
		if 0 < len( need_program_numbers ):
			if not( program_number in need_program_numbers ) and not( phdr.preset in need_program_numbers ):
				continue
		# 追加
		self._read_soundfont_preset_compose_sample( sf, preset )
		self.presets[program_number] = preset

		#times.append( Time.get_ticks_msec( ) )

	#for i in range( len( times ) - 1 ):
	#	var diff:int = times[i+1] - times[i]
	#	if 10 <= diff:
	#		printt( i, diff )
	#printt( "all", times[-1] - times[0] )

func _read_soundfont_pdta_inst( sf:SoundFont.SoundFontData ) -> Array:
	#
	# サウンドフォントからプリセットデータを読み込む
	# @param	sf	サウンドフォントデータ
	# @return	プリセットデータ
	#

	var sf_insts:Array = Array( )
	var bag_index:int = 0
	var gen_index:int = 0
	var pdta:SoundFont.SoundFontPresetData = sf.pdta
	var insts:Array = pdta.inst
	var ibags:Array = pdta.ibag
	var igens:Array = pdta.igen
	var shdrs:Array = pdta.shdr

	for inst_index in range( 0, len( insts ) - 1 ):
		var inst:SoundFont.SoundFontInstrument = insts[inst_index]
		var sf_inst:TempSoundFontInstrument = TempSoundFontInstrument.new( )

		var bag_next:int = insts[inst_index+1].inst_bag_ndx
		var global_bag:TempSoundFontInstrumentBag = TempSoundFontInstrumentBag.new( )
		for bag_count in range( bag_index, bag_next ):
			var bag:TempSoundFontInstrumentBag = global_bag.duplicate( )
			var gen_next:int = ibags[bag_count+1].gen_ndx
			for gen_count in range( gen_index, gen_next ):
				var gen:SoundFont.SoundFontGenerator = igens[gen_count]
				match gen.gen_oper:
					SoundFont.gen_oper_key_range:
						bag.key_range.high = gen.uamount >> 8
						bag.key_range.low = gen.uamount & 0xFF
					SoundFont.gen_oper_vel_range:
						bag.vel_range.high = gen.uamount >> 8
						bag.vel_range.low = gen.uamount & 0xFF
					SoundFont.gen_oper_overriding_root_key:
						bag.original_key = gen.amount
					SoundFont.gen_oper_start_addrs_offset:
						bag.sample_start_offset += gen.amount
					SoundFont.gen_oper_end_addrs_offset:
						bag.sample_end_offset += gen.amount
					SoundFont.gen_oper_start_addrs_coarse_offset:
						bag.sample_start_offset += gen.amount * 32768
					SoundFont.gen_oper_end_addrs_coarse_offset:
						bag.sample_end_offset += gen.amount * 32768
					SoundFont.gen_oper_startloop_addrs_offset:
						bag.sample_start_loop_offset += gen.amount
					SoundFont.gen_oper_endloop_addrs_offset:
						bag.sample_end_loop_offset += gen.amount
					SoundFont.gen_oper_startloop_addrs_coarse_offset:
						bag.sample_start_loop_offset += gen.amount * 32768
					SoundFont.gen_oper_endloop_addrs_coarse_offset:
						bag.sample_end_loop_offset += gen.amount * 32768
					SoundFont.gen_oper_coarse_tune:
						bag.coarse_tune = gen.amount
					SoundFont.gen_oper_fine_tune:
						bag.fine_tune = gen.amount
					SoundFont.gen_oper_keynum:
						bag.keynum = gen.amount
					SoundFont.gen_oper_attack_vol_env:
						bag.adsr.attack_vol_env_time = pow( 2.0, float( gen.amount ) / 1200.0 )
					SoundFont.gen_oper_decay_vol_env:
						bag.adsr.decay_vol_env_time = pow( 2.0, float( gen.amount ) / 1200.0 )
					SoundFont.gen_oper_release_vol_env:
						bag.adsr.release_vol_env_time = pow( 2.0, float( gen.amount ) / 1200.0 )
					SoundFont.gen_oper_sustain_vol_env:
						# -144 db == sound font 1440
						bag.adsr.sustain_vol_env_db = -clamp( float( gen.amount ), 0.0, 1440.0 ) / 10.0
					SoundFont.gen_oper_sample_modes:
						bag.sample_modes = gen.uamount
					SoundFont.gen_oper_sample_id:
						bag.sample_id = gen.uamount
						bag.sample = shdrs[gen.amount]
						if bag.original_key == 255:
							bag.original_key = bag.sample.original_key
					SoundFont.gen_oper_initial_attenuation:
						bag.volume_db = -clamp( float( gen.amount ), 0.0, 1440.0 ) / 10.0
					#_:
					#	print( gen.gen_oper )
			# global zoneでない場合
			if bag.sample != null:
				sf_inst.bags.append( bag )
			else:
				global_bag = bag
			gen_index = gen_next
		sf_insts.append( sf_inst )
		bag_index = bag_next

	return sf_insts

func _read_soundfont_preset_compose_sample( sf:SoundFont.SoundFontData, preset:Preset ) -> void:
	#
	# サウンドフォントから波形を取り出してプリセットに追加する
	# @warning この関数は「長大関数」化しているが、GDScriptのメンバ関数呼び出しが遅いためすべてインライン展開したのが原因。いずれ、Godot EngineのVMが高速化したら関数を分割する予定。
	# @param	sf		サウンドフォントデータ
	# @param	preset	プリセット
	#

	var sample_base:PackedByteArray = sf.sdta.smpl
	var loaded_sample_data:Dictionary = Dictionary( )
	var log2:float = log( 2.0 )

	var append_head_silent:PackedByteArray = self.head_silent
	var append_head_silent_samples:int = self.head_silent_samples

	for pbag_index in range( 0, preset.bags.size( ) ):
		var pbag:TempSoundFontBag = preset.bags[pbag_index]

		for ibag_index in range( 0, pbag.instrument.bags.size( ) ):
			var ibag:TempSoundFontInstrumentBag = pbag.instrument.bags[ibag_index]
			if ibag.vel_range.high < 100: continue
			var sample:SoundFont.SoundFontSampleHeader = ibag.sample
			var array_stream:Array = Array( )
			var array_base_pitch:PackedFloat32Array = PackedFloat32Array( )

			for i in range( 0, 2 ):
				var start:int = sample.start + ibag.sample_start_offset
				var end:int = sample.end + ibag.sample_end_offset
				var start_loop:int = sample.start_loop + ibag.sample_start_loop_offset
				var end_loop:int = sample.end_loop + ibag.sample_end_loop_offset
				var base_pitch:float = ( pbag.coarse_tune + ibag.coarse_tune ) / 12.0 + ( pbag.fine_tune + ibag.sample.pitch_correction + ibag.fine_tune ) / 1200.0
				if sample.sample_rate != 44100:
					var f:float = float( sample.sample_rate ) / 44100.0
					base_pitch += log( f ) / log2

				var loaded_key:String = "%d_%d_%d_%d_%d_%f" % [start, end, start_loop, end_loop, sample.sample_rate, base_pitch]

				if loaded_key in loaded_sample_data:
					array_stream.append( loaded_sample_data[loaded_key] )
				else:
					var ass: = AudioStreamWAV.new( )

					ass.data = append_head_silent + sample_base.slice( start * 2, end * 2 - 1 )
					ass.format = AudioStreamWAV.FORMAT_16_BITS
					ass.mix_rate = 44100
					ass.stereo = false
					ass.loop_mode = AudioStreamWAV.LOOP_DISABLED
					if ( ibag.sample_modes == SoundFont.sample_mode_loop_continuously ) or ( start + 64 <= start_loop and ibag.sample_modes == -1 and preset.number != drum_track_bank << 7 ):
						ass.loop_mode = AudioStreamWAV.LOOP_FORWARD
						ass.loop_begin = start_loop - start + append_head_silent_samples
						ass.loop_end = end_loop - start + append_head_silent_samples

					loaded_sample_data[loaded_key] = ass

					array_stream.append( ass )

				array_base_pitch.append( base_pitch )

				if sample.sample_type != SoundFont.sample_link_mono_sample and sample.sample_type != SoundFont.sample_link_rom_mono_sample:
					sample = sf.pdta.shdr[sample.sample_link]
				else:
					break

			var key_range:TempSoundFontRange = ibag.key_range
			var vel_range:TempSoundFontRange = ibag.vel_range
			var vel_range_min:int = vel_range.low
			var vel_range_max:int = vel_range.high

			# ADSRステート生成
			var adsr:TempSoundFontInstrumentBagADSR = ibag.adsr
			var a:float = adsr.attack_vol_env_time
			var d:float = adsr.decay_vol_env_time
			var s:float = adsr.sustain_vol_env_db
			var r:float = adsr.release_vol_env_time
			var volume_db:float = ibag.volume_db
			var ads_state:Array
			if 0.001 < a:
				ads_state = [
					VolumeState.new( 0.0, -144.0 ),
					VolumeState.new( a, 0.0 ),
					VolumeState.new( a+d, s ),
				]
			else:
				ads_state = [
					VolumeState.new( 0.0, 0.0 ),
					VolumeState.new( d, s ),
				]
			var release_state:Array = [
				VolumeState.new( 0.0, s ),
				VolumeState.new( r, -144.0 ),
			]
			for key_number in range( key_range.low, key_range.high + 1 ):
				#if preset.number == drum_track_bank << 7:
				#	if 36 <= key_number and key_number <= 40:
				#		print( key_number, " # ", ibag.sample.name, " # ", volume_db );
				var instrument:Instrument = Instrument.new( )
				if preset.instruments[key_number] == null:
					preset.instruments[key_number] = [ instrument ]
				else:
					preset.instruments[key_number].append( instrument )
				instrument.preset = preset
				instrument.array_base_pitch = array_base_pitch
				if ibag.original_key != 255:
					var shift_pitch:float = float( key_number - ibag.original_key ) / 12.0
					for k in range( len( instrument.array_base_pitch ) ):
						instrument.array_base_pitch[k] += shift_pitch
				instrument.array_stream = array_stream

				instrument.volume_db = volume_db
				instrument.ads_state = ads_state
				instrument.release_state = release_state
				instrument.vel_range_min = vel_range_min
				instrument.vel_range_max = vel_range_max

func _notification( what:int ):
	#
	# 通知（メモリ破棄用）
	# @param	what	通知要因
	#

	if what == NOTIFICATION_PREDELETE:
		for i in self.presets.keys( ):
			var preset:Preset = self.presets[i]
			preset.instruments = Array()
			preset.bags = Array()
