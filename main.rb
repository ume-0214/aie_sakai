#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'FileReader'
require 'DbManager'
require 'SeedsManager'
require 'CommonsManager'
require 'csv_writer'

# 閾値αの設定
t_a = ARGV[0]

# 使用するデータベースのパス
dbPath = "/home/ume/workspace/experiment_data/kakaku_db/Camera.naist_db"

# 使用するカテゴリーのパス
filePath = "normalized_sentence.txt"

# 初期評価表現のパス
init_path = "init_seed_100.txt"

# 種表現と共通頻出表現を格納する配列の初期化
seeds = []
commons = []

# 初期評価表現の格納
open(init_path) do |io|
  io.readlines.each do |line|
    next if line[0] == "#"
    ary = line.chomp.split(",")
    seeds << Seed.new(ary[0], ary[1], ary[2])
  end
end

# 種表現を格納する配列の初期化
#seeds =[Seed.new("が良い", "が", "良い"), Seed.new("が悪い", "が", "悪い")]

selectedSeeds = seeds.clone
init = seeds.length

reader = FileReader.new(filePath)
dbManager = DbManager.new(dbPath)
seedsManager = SeedsManager.new(seeds.clone, dbManager)
commonsManager = CommonsManager.new(commons.clone, dbManager)

corpus = reader.read

# データベースを開く
dbManager.open

for i in 0..4

  tmp_seed = {}
  tmp_common = {}

  # 種表現を含んでいる文の取得
  selectedSeeds.each do |s|
    sentences = corpus.select{|sentence| sentence.include?(s.other)}
    tmp_seed[s] = sentences
  end

  # 共通頻出元候補の獲得
  tmp_seed.each do |s, sentences|
    sentences.each do |sentence|
#      candidateCommons = seedsManager.getCandidateCommons(s, sentence)
      tree = dbManager.getTree(sentence)
      candidateCommons = s.getCommons(tree)
      candidateCommons.map{|candidateCommon| commonsManager.add(candidateCommon, s)}
    end
  end

  selectedCommons = commonsManager.select(seeds, t_a)
  commons |= selectedCommons

  # csvへの書き込み
  write_common_status(i + 1, init.to_s, t_a, seeds, commonsManager)

  selectedCommons.each do |e|
    p e.name.toutf8
  end
  print "-----------------------------------\n"

  commons.each do |e|
    p e.name.toutf8
  end
  print "-----------------------------------\n"

  break if selectedCommons.length == 0

  # 共通頻出表現を含んでいる文を取得
  selectedCommons.each do |c|
    sentences = corpus.select{|sentence| sentence.include?(c.name)}
    tmp_common[c] = sentences
  end

  # 種表現候補の獲得
  tmp_common.each do |c, sentences|
    sentences.each do |sentence|
#      candidateSeeds = commonsManager.getCandidateSeeds(c, sentence)
      tree = dbManager.getTree(sentence)
      candidateSeeds = c.getSeeds(tree)
      candidateSeeds.map{|candidateSeed| seedsManager.add(candidateSeed, c)}
    end
  end

  selectedSeeds = seedsManager.select(commons, t_a)
  seeds |= selectedSeeds

  # csvファイルへの書き込み
  write_seed_status(i + 1, init.to_s, t_a, commons, seedsManager)

  selectedSeeds.each do |seed|
    p seed.name.toutf8
  end
  print "-----------------------------------\n"

  seeds.each do |seed|
    p seed.name.toutf8
  end
  print "-----------------------------------\n"

  break if selectedSeeds.length == 0

end

# データベースを閉じる
dbManager.close
