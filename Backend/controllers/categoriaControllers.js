const conexion = require('../DBConection/db');

// Crear Categoría (solo usuarios con rol Operador)
exports.createCategoria = async (req, res) => {
    const pool = await conexion();
    const { idusuarios, rol_idrol } = req.user; // Datos del token
    const { estados_idestados, nombre } = req.body;

    try {
        // Verificar si el rol es Operador
        if (rol_idrol !== 2) { // Operador es id = 2
            return res.status(403).json({ msg: 'Solo los usuarios con rol Operador pueden crear categorías' });
        }

        // Ejecutar procedimiento almacenado
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC p_InsertarCategoriaProd
                @usuarios_idusuarios = :usuarios_idusuarios, 
                @estados_idestados =:estados_idestados,  
                @nombre=:nombre,
                @mensaje = @mensaje OUTPUT;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: { 
                    usuarios_idusuarios: idusuarios,
                    estados_idestados,
                    nombre 
                },
            }
        );

        // Obtener el mensaje del resultado
        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al insertar la categoría:', error);
        res.status(500).json({ error: 'Error al insertar la categoría' });
    } finally {
        await pool.close();
    }
};

// Obtener Categorías (solo las creadas por el usuario actual)
exports.getCategoria = async (req, res) => {
    const pool = await conexion();
    const { idusuarios } = req.user; // Datos del token

    try {
        const [categorias] = await pool.query(
            'SELECT * FROM CategoriaProductos WHERE usuarios_idusuarios = :idusuarios',
            { replacements: { idusuarios } }
        );

        res.status(200).json({ msg: 'Categorías encontradas', categorias });
    } catch (error) {
        console.error('Error al obtener las categorías:', error);
        res.status(500).json({ msg: 'Error al obtener las categorías' });
    } finally {
        await pool.close();
    }
};

// Actualizar Categoría (solo el creador puede actualizar)
exports.updateCategoria = async (req, res) => {
    const pool = await conexion();
    const { id } = req.params;
    const { idusuarios } = req.user; // Datos del token
    const { estados_idestados, nombre } = req.body;

    try {
        // Verificar si el usuario es el creador de la categoría
        const [categoria] = await pool.query(
            'SELECT usuarios_idusuarios FROM CategoriaProductos WHERE idCategoriaProductos = :id',
            { replacements: { id } }
        );

        if (!categoria.length || categoria[0].usuarios_idusuarios !== idusuarios) {
            return res.status(403).json({ msg: 'No tienes permiso para actualizar esta categoría' });
        }

        // Actualizar categoría
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC p_ActualizarCategoria
                @idCategoriaProductos = :id,
                @usuarios_idusuarios = :usuarios_idusuarios,
                @estados_idestados = :estados_idestados,
                @nombre = :nombre,
                @mensaje = @mensaje OUTPUT;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: {
                    id,
                    usuarios_idusuarios: idusuarios,
                    estados_idestados,
                    nombre,
                },
            }
        );

        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al actualizar la categoría:', error);
        res.status(500).json({ msg: 'Error al actualizar la categoría' });
    } finally {
        await pool.close();
    }
};
