# Diagnóstico de propiedad (user_id) de álbumes.
# Uso en el server de producción:
#   bin/rails runner scripts/diagnose_albums_ownership.rb
#
# Opcional: cambia el email si no es el correcto.
email = ENV.fetch("DIAG_EMAIL", "gabrielreyesb@gmail.com")

u = User.find_by(email: email)
abort "No existe usuario #{email}" unless u

puts "=" * 60
puts "Usuario: #{u.email} (id=#{u.id})"
puts "-" * 60
puts "Album.count (todos):           #{Album.count}"
puts "Tus álbumes (u.albums.count):  #{u.albums.count}"
puts "Álbumes con user_id NULL:      #{Album.where(user_id: nil).count}"
puts "Álbumes de OTROS usuarios:     #{Album.where.not(user_id: [u.id, nil]).count}"
puts "Reparto por user_id:           #{Album.group(:user_id).count.inspect}"
puts "=" * 60

# Buscar el género problemático
genres = Genre.where("LOWER(name) LIKE ?", "%metal progres%").to_a
if genres.empty?
  puts "No se encontró ningún género que contenga 'metal progres'."
  puts "Géneros disponibles (id, name, user_id):"
  Genre.order(:name).each { |g| puts "  #{g.id}\t#{g.name.inspect}\tuser_id=#{g.user_id.inspect}" }
else
  genres.each do |g|
    puts "Género id=#{g.id} #{g.name.inspect} user_id=#{g.user_id.inspect}"
    puts "  Álbumes con este genre_id (todos):  #{Album.where(genre_id: g.id).count}"
    puts "  Tuyos con este genre_id:            #{u.albums.where(genre_id: g.id).count}"
    puts "  Reparto por user_id:                #{Album.where(genre_id: g.id).group(:user_id).count.inspect}"
    puts "  Autores de este género:             #{g.authors.count}"
    # ¿Los álbumes tienen genre_id seteado o el género solo está en el autor?
    via_author = Album.joins(:author).where(authors: { genre_id: g.id }).count
    puts "  Álbumes cuyo AUTOR es de este género: #{via_author}"
    puts "  De esos, con album.genre_id NULL:    #{Album.joins(:author).where(authors: { genre_id: g.id }, albums: { genre_id: nil }).count}"
    puts "-" * 60
  end
end
