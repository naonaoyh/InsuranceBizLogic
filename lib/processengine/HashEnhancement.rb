class Hash

  def deep_merge0(hash)
        target = dup

        hash.keys.each do |key|
          if hash[key].is_a? Hash and self[key].is_a? Hash
            target[key] = target[key].deep_merge(hash[key])
            next
          end

         target[key] = hash[key]
        end

        target
      end

      def deep_merge!(second)
        second.each_pair do |k,v|
          if self[k].is_a?(Hash) and second[k].is_a?(Hash)
            self[k].deep_merge!(second[k])
          else
            self[k] = second[k]
          end
        end
      end


       def deep_merge2(other)
         deep_proc = Proc.new { |k, s, o|
             if s.kind_of?(Hash) && o.kind_of?(Hash)
                next s.merge(o, &deep_proc)
             end
             next o
          }
          merge(other, &deep_proc)
       end


       def deep_merge(second)
          merger = proc { |key,v1,v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
          self.merge(second, &merger)
       end


       def keep_merge(hash)
          target = dup
          hash.keys.each do |key|
             if hash[key].is_a? Hash and self[key].is_a? Hash
                target[key] = target[key].keep_merge(hash[key])
                next
             end
             #target[key] = hash[key]
             target.update(hash) { |key, *values| values.flatten.uniq }
          end
          target
       end

    end
