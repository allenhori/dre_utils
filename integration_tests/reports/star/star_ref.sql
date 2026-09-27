select {{ dre_utils.star(ref('sub'), except=['id']) }} from {{ ref('sub') }} s order by doubled
