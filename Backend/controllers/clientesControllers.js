const conexion = require('../DBConection/db')

//Post Clientes
exports.createCliete = async (req, res) => {
    const pool = await conexion(); 
    const { razon_social, nombre_comercial, direccion_entrega, telefono, email } = req.body;

    try {
        // Ejecuta el procedimiento almacenado y captura el resultado
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC p_InsertarClientes 
                @razon_social = :razon_social, 
                @nombre_comercial = :nombre_comercial, 
                @direccion_entrega = :direccion_entrega, 
                @telefono = :telefono, 
                @email = :email;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: { razon_social, nombre_comercial, direccion_entrega, telefono, email },
            }
        );

        // Obtén el mensaje devuelto desde el resultado
        const mensaje = result[0]?.mensaje;  // Captura el mensaje del SELECT
        res.json({ msg: mensaje }); // Devuelve el mensaje al cliente
    } catch (error) {
        console.error('Error al insertar cliente:', error);
        res.status(500).json({ error: 'Error al insertar cliente' });
    } finally {
        await pool.close(); // Cierra la conexión
    }
    
};


//Get Clientes
exports.getCliente = async(req, res) => {
    const pool = await conexion()

    try {
        const clients = await pool.query('select * from Clientes')
        res.status(200).json({msg:'Cliente encontrados', clients:clients[0]})
    } catch (error) {
        console.log(error, 'Error al obtener Clientes')
        res.status(500).json({msg:'Error al obtener Clientes'})
    } finally {
        await pool.close(); // Cierra la conexión
    }
}

//Patch Clientes
exports.updateEstado = async (req, res) => {
    const pool = await conexion();

    const { id } = req.params;
    const { razon_social, nombre_comercial, direccion_entrega, telefono, email } = req.body;

    try {
        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC p_ActualizarClientes 
                @idClientes = :id, 
                @razon_social = :razon_social, 
                @nombre_comercial = :nombre_comercial, 
                @direccion_entrega = :direccion_entrega, 
                @telefono = :telefono, 
                @email = :email;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: {
                    id,
                    razon_social,
                    nombre_comercial,
                    direccion_entrega,
                    telefono,
                    email,
                },
            }
        );
        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al actualizar cliente:', error);
        res.status(500).json({ msg:'Error al actualizar cliente' });
    }
    finally {
        await pool.close(); // Cierra la conexión
    }
};
