require 'rubygems'
require 'sinatra'

#e exigencia
#p puntaje máximo
#s step
#m nota mínima

module Rack
  class Request
    def ip
      if addr = @env['HTTP_X_FORWARDED_FOR']
        addr.split(',').last.strip
      else
        @env['REMOTE_ADDR']
      end
    end
  end
end

class Array
  def chunk(size=2)
    chunks = []
    start = 0
    1.upto((self.length/size).ceil+1) do |i|
      last = start+size-1
      chunks << self[start..last] unless self[start..last].empty?
      start = last+1
    end
    chunks
  end
end

get '' do
redirect 'escala/'
end

get '/' do
  default_params = {:exig => 60 , :pmax => 10, :paso => 1, :nmin => 2, :nmax => 7, :napr => 4}
  default_params.each{|k,v| params[k] = v if (!params[k] or params[k].empty?)}
  params.each{|k,v| params[k]=v.to_s.gsub(",",".").to_f}
  params[:exig] = params[:exig]/100.0
  params[:pmax] = 1000 if params[:pmax] > 1000
  params[:paso] = 1.0 if params[:paso] == 0
  params[:paso] = 0.01 if params[:paso] < 0.01
  @notas = (0..params[:pmax]/params[:paso]).map{|p| [p*params[:paso],nota(p*params[:paso])]}
  @notas = @notas.chunk(15)

  params[:exig] = params[:exig]*100
  erb :escala
end

get '/stats' do
  @accesos = contar_accesos
  erb :accesos
end

private

def nota(ptje) 
  if(ptje<params[:exig]*params[:pmax])
    nota=(params[:napr]-params[:nmin])*ptje/(params[:exig]*params[:pmax])+params[:nmin] 
  else
    nota=(params[:nmax]-params[:napr])*(ptje-params[:exig]*params[:pmax])/(params[:pmax]*(1-params[:exig]))+params[:napr]
  end
  return nota
end


def contar_accesos
  count = {}

  File::open('access.log', "r") do |f|
    f.read.split("\n").each do |l|
    l=l.gsub(/.*\[(.*)-..T.*\].*/,'\1')
    if l=~/\d{4}-\d{2}/
      if count[l].nil?
        count[l] = 1
      else
        count[l]+=1
      end
    end
  end
  return count.sort
  end
end
