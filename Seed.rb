#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'

# 種表現クラス
class Seed

  # 種表現
  attr_reader :name

  # 種表現の助詞
  attr_reader :particle

  # 種表現の助詞以外の形態素列
  attr_reader :other
	
  # 種表現から得られた共通頻出表現
  attr_reader :commons

  # 種表現のエントロピー
  attr_accessor :entropy

  def initialize(seed, particle, other, commons = {})
    @name = seed
    @particle = particle
    @other = other
    @commons = commons
  end

  # 共通頻出表現の追加
  def add_common(common)
    if @commons.key?(common)
      @commons[common] += 1
    elsif
      @commons.store(common, 1)
    end
  end

  # 共通頻出表現の取得
  def each_common
    @commons.each_key do |common|
      yield common
    end
  end

  # 与えられた共通頻出表現の個数を取得
  def get_common_count(common)
    return @commons[common]
  end

  # 種表現の総数を獲得
  def getSeedsCount(total = 0)
    @commons.each_value do |count|
      total += count
    end

    return total
  end

  # 種表現を助詞とその他の形態素列に分解
#  def setParticle(tree)
#    particles = tree.getParticles
#    
#    particles.each do |element|
#      temp = @name.split(//u)[element.split(//u).length..@name.split(//u).length-1].to_s
#      other = temp if tree.searchString(temp)
#
#      particle = @name.split(//u)[0..element.split(//u).length-1].to_s
#
#      if other != nil && particle == element
#        @other = other
#        @particle = particle
#        break
#      end
#
#    end
#
#    if @particle == nil && @other == nil
#      return false
#    elsif @particle != nil && @other != nil
#      return true
#    end
#  end

  # 共通頻出表現候補の獲得
  def getCommons(tree, commons = [])
    segments = tree.getSegments(@other)

    segments.each do |segment|
      s = segment.cut_symbol

      next if s != @other

      preSegments = tree.getPreSegments(segment)

      preSegments.each do |segment|
        # 代名詞、非自立、形容動詞語幹、動詞、助動詞は除去
        stopword = segment.tokens.select{|token| token.has_pronoun? || token.has_anti_independence? || token.has_adjective_suffix? || token.has_verb? || token.has_auxiliary_verb?}
        next unless stopword.empty?

        if segment.getParticle == @particle
          string = segment.cut_symbol
          common = string[0..(string.length - @particle.length - 1)]
          commons << Common.new(common) unless common =~ /^[+-]?\d+$/
        end
      end
    end

    return commons
  end

end
