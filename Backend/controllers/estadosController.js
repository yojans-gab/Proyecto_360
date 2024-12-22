const conexion = require('../DBConection/db')

//Post Estados
exports.createEstado = async (req, res) => {
    const pool = await conexion(); 
    const { nombre } = req.body;

    try {
        // Ejecuta el procedimiento almacenado y captura el resultado
        const [result] = await pool.query(
            `DECLARE @resultado NVARCHAR(50);
             EXEC p_InsertarEstados
                 @nombre=:nombre,
                 @resultado=@resultado OUTPUT;
             SELECT @resultado AS mensaje;`,
            {
                replacements: { nombre },
            }
        );

        // Obtén el mensaje devuelto desde el resultado
        const mensaje = result[0]?.mensaje; // Captura el mensaje del SELECT
        res.json({ msg: mensaje }); // Devuelve el mensaje al cliente
    } catch (error) {
        console.error('Error al insertar estado:', error);
        res.status(500).json({ error: 'Error al insertar estado' });
    } finally {
        await pool.close(); // Cierra la conexión
    }
    
};


//Get Estados
exports.getEstado = async(req, res) => {
    const pool = await conexion()

    try {
        const estates = await pool.query('select * from estados')
        res.status(200).json({msg:'Estados encontrados', estates:estates[0]})
    } catch (error) {
        console.log(error, 'Error al obtener Estados')
        res.status(500).json({msg:'Error al obtener Estados'})
    } finally {
        await pool.close(); // Cierra la conexión
    }
}

exports.updateEstado = async (req, res) => {
    const pool = await conexion();

    const { id } = req.params;
    const { nuevo_nombre } = req.body;

    try {
        const [result] = await pool.query(
            `
            DECLARE @mensaje NVARCHAR(50);
            EXEC p_ActualizarEstado
                @idestados = :id,
                @nombre = :nuevo_nombre,
                @mensaje = @mensaje OUTPUT;
            SELECT @mensaje AS mensaje;
            `,
            {
                replacements: {
                    id,
                    nuevo_nombre,
                },
            }
        );
        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al actualizar estado:', error);
        res.status(500).json({ msg: 'Error al actualizar estado' });
    }
    finally {
        await pool.close(); // Cierra la conexión
    }
};
